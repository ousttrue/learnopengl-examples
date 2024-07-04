pub const packages = struct {
    pub const @"12200ba39d83227f5de08287b043b011a2eb855cdb077f4b165edce30564ba73400e" = struct {
        pub const build_root = "C:\\Users\\ousttrue\\AppData\\Local\\zig\\p\\12200ba39d83227f5de08287b043b011a2eb855cdb077f4b165edce30564ba73400e";
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"12208af0258178372af254d34e32e7f6cdf2e0f6a51bfb8d6706aff159e2ec6d2c65" = struct {
        pub const build_root = "C:\\Users\\ousttrue\\AppData\\Local\\zig\\p\\12208af0258178372af254d34e32e7f6cdf2e0f6a51bfb8d6706aff159e2ec6d2c65";
        pub const build_zig = @import("12208af0258178372af254d34e32e7f6cdf2e0f6a51bfb8d6706aff159e2ec6d2c65");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "emsdk", "12200ba39d83227f5de08287b043b011a2eb855cdb077f4b165edce30564ba73400e" },
        };
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "sokol", "12208af0258178372af254d34e32e7f6cdf2e0f6a51bfb8d6706aff159e2ec6d2c65" },
};
