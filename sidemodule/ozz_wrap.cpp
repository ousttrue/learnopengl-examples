#include "ozz_wrap.h"

// ozz-animation headers
#include "ozz/animation/runtime/animation.h"
#include "ozz/animation/runtime/local_to_model_job.h"
#include "ozz/animation/runtime/sampling_job.h"
#include "ozz/animation/runtime/skeleton.h"
#include "ozz/base/containers/vector.h"
#include "ozz/base/io/archive.h"
#include "ozz/base/io/stream.h"
#include "ozz/base/maths/soa_transform.h"
#include "ozz/base/maths/vec_float.h"

extern "C" {

// wrapper struct for managed ozz-animation C++ objects, must be deleted
// before shutdown, otherwise ozz-animation will report a memory leak
struct ozz_t {
  ozz::animation::Skeleton skeleton;
  ozz::animation::Animation animation;
  ozz::animation::SamplingCache cache;
  ozz::vector<ozz::math::SoaTransform> local_matrices;
  ozz::vector<ozz::math::Float4x4> model_matrices;
};

ozz_t *OZZ_init() { return new ozz_t; }
void OZZ_shutdown(void *p) { delete ((ozz_t *)p); }

bool OZZ_load_skeleton(ozz_t *p, const void *ptr, size_t size) {
  // NOTE: if we derived our own ozz::io::Stream class we could
  // avoid the extra allocation and memory copy that happens
  // with the standard MemoryStream class
  ozz::io::MemoryStream stream;
  stream.Write(ptr, size);
  stream.Seek(0, ozz::io::Stream::kSet);
  ozz::io::IArchive archive(&stream);
  if (archive.TestTag<ozz::animation::Skeleton>()) {
    archive >> p->skeleton;
    const int num_soa_joints = p->skeleton.num_soa_joints();
    const int num_joints = p->skeleton.num_joints();
    p->local_matrices.resize(num_soa_joints);
    p->model_matrices.resize(num_joints);
    p->cache.Resize(num_joints);
    return true;
  } else {
    return false;
  }
}

bool OZZ_load_animation(ozz_t *p, const void *ptr, size_t size) {
  ozz::io::MemoryStream stream;
  stream.Write(ptr, size);
  stream.Seek(0, ozz::io::Stream::kSet);
  ozz::io::IArchive archive(&stream);
  if (archive.TestTag<ozz::animation::Animation>()) {
    archive >> p->animation;
    return true;
  } else {
    return false;
  }
}

bool OZZ_load_mesh(ozz_t *p, const void *ptr, size_t size) { return false; }

void OZZ_eval_animation(ozz_t *p, float anim_ratio) {
  // sample animation
  ozz::animation::SamplingJob sampling_job;
  sampling_job.animation = &p->animation;
  sampling_job.cache = &p->cache;
  sampling_job.ratio = anim_ratio;
  sampling_job.output = make_span(p->local_matrices);
  sampling_job.Run();

  // convert joint matrices from local to model space
  ozz::animation::LocalToModelJob ltm_job;
  ltm_job.skeleton = &p->skeleton;
  ltm_job.input = make_span(p->local_matrices);
  ltm_job.output = make_span(p->model_matrices);
  ltm_job.Run();
}

float OZZ_duration(ozz_t *p) { return p->animation.duration(); }
size_t OZZ_num_joints(ozz_t *p) { return p->skeleton.num_joints(); }
const short *OZZ_joint_parents(ozz_t *p) {
  return p->skeleton.joint_parents().data();
}
const float *OZZ_model_matrices(ozz_t *ozz, size_t joint_index) {
  return (float *)&ozz->model_matrices[joint_index];
}

void OZZ_update_joints(ozz_t *p){

    // const anim_duration = state.ozz.*.animation.duration();
    //     for (int instance = 0; instance < state.num_instances; instance++) {
    //
    //         // each character instance evaluates its own animation
    //         const float anim_ratio = fmodf(((float)state.time.abs_time_sec + (instance*0.1f)) / anim_duration, 1.0f);
    //
    //         // sample animation
    //         // NOTE: using one cache per instance versus one cache per animation
    //         // makes a small difference, but not much
    //         ozz::animation::SamplingJob sampling_job;
    //         sampling_job.animation = &state.ozz->animation;
    //         sampling_job.cache = &state.ozz->cache;
    //         sampling_job.ratio = anim_ratio;
    //         sampling_job.output = make_span(state.ozz->local_matrices);
    //         sampling_job.Run();
    //
    //         // convert joint matrices from local to model space
    //         ozz::animation::LocalToModelJob ltm_job;
    //         ltm_job.skeleton = &state.ozz->skeleton;
    //         ltm_job.input = make_span(state.ozz->local_matrices);
    //         ltm_job.output = make_span(state.ozz->model_matrices);
    //         ltm_job.Run();
    //
    //         // compute skinning matrices and write to joint texture upload buffer
    //         for (int i = 0; i < state.num_skin_joints; i++) {
    //             ozz::math::Float4x4 skin_matrix = state.ozz->model_matrices[state.ozz->joint_remaps[i]] * state.ozz->mesh_inverse_bindposes[i];
    //             const ozz::math::SimdFloat4& c0 = skin_matrix.cols[0];
    //             const ozz::math::SimdFloat4& c1 = skin_matrix.cols[1];
    //             const ozz::math::SimdFloat4& c2 = skin_matrix.cols[2];
    //             const ozz::math::SimdFloat4& c3 = skin_matrix.cols[3];
    //
    //             float* ptr = &joint_upload_buffer[instance][i][0][0];
    //             *ptr++ = ozz::math::GetX(c0); *ptr++ = ozz::math::GetX(c1); *ptr++ = ozz::math::GetX(c2); *ptr++ = ozz::math::GetX(c3);
    //             *ptr++ = ozz::math::GetY(c0); *ptr++ = ozz::math::GetY(c1); *ptr++ = ozz::math::GetY(c2); *ptr++ = ozz::math::GetY(c3);
    //             *ptr++ = ozz::math::GetZ(c0); *ptr++ = ozz::math::GetZ(c1); *ptr++ = ozz::math::GetZ(c2); *ptr++ = ozz::math::GetZ(c3);
    //         }
    //     }

}

} // extern "C"
