const std = @import("std");

// nettle's core library sources (nettle_SOURCES from Makefile.in), built
// portably (no per-arch assembly): nettle keeps hand-written asm
// optimizations for x86/x86_64/arm/arm64/powerpc64/s390x/sparc64 in their
// own subdirectories, selected by configure/its "fat" (runtime CPU
// dispatch) build; none of that is referenced here, so every primitive
// below uses its plain-C fallback implementation (the same one used on
// any platform configure doesn't have optimized asm for) -- correct,
// just not as fast as a native build with -O3 -march=native + asm would
// be. hogweed (the GMP-dependent public-key half: RSA/DSA/ECC/sexp/...)
// is NOT built here; see build.zig's module comment.
const nettle_sources = [_][]const u8{
    "aes-decrypt-internal.c",
    "aes-decrypt-table.c",
    "aes128-decrypt.c",
    "aes192-decrypt.c",
    "aes256-decrypt.c",
    "aes-encrypt-internal.c",
    "aes-encrypt-table.c",
    "aes128-encrypt.c",
    "aes192-encrypt.c",
    "aes256-encrypt.c",
    "aes-invert-internal.c",
    "aes-set-key-internal.c",
    "aes128-set-encrypt-key.c",
    "aes128-set-decrypt-key.c",
    "aes128-meta.c",
    "aes192-set-encrypt-key.c",
    "aes192-set-decrypt-key.c",
    "aes192-meta.c",
    "aes256-set-encrypt-key.c",
    "aes256-set-decrypt-key.c",
    "aes256-meta.c",
    "nist-keywrap.c",
    "arcfour.c",
    "arctwo.c",
    "arctwo-meta.c",
    "blowfish.c",
    "blowfish-bcrypt.c",
    "balloon.c",
    "balloon-sha1.c",
    "balloon-sha256.c",
    "balloon-sha384.c",
    "balloon-sha512.c",
    "base16-encode.c",
    "base16-decode.c",
    "base64-encode.c",
    "base64-decode.c",
    "base64url-encode.c",
    "base64url-decode.c",
    "buffer.c",
    "buffer-init.c",
    "camellia-crypt-internal.c",
    "camellia-table.c",
    "camellia-absorb.c",
    "camellia-invert-key.c",
    "camellia128-set-encrypt-key.c",
    "camellia128-crypt.c",
    "camellia128-set-decrypt-key.c",
    "camellia128-meta.c",
    "camellia192-meta.c",
    "camellia256-set-encrypt-key.c",
    "camellia256-crypt.c",
    "camellia256-set-decrypt-key.c",
    "camellia256-meta.c",
    "cast128.c",
    "cast128-meta.c",
    "cbc.c",
    "cbc-aes128-encrypt.c",
    "cbc-aes192-encrypt.c",
    "cbc-aes256-encrypt.c",
    "ccm.c",
    "ccm-aes128.c",
    "ccm-aes192.c",
    "ccm-aes256.c",
    "cfb.c",
    "siv-cmac.c",
    "siv-cmac-aes128.c",
    "siv-cmac-aes256.c",
    "siv-gcm.c",
    "siv-gcm-aes128.c",
    "siv-gcm-aes256.c",
    "cnd-memcpy.c",
    "chacha-crypt.c",
    "chacha-core-internal.c",
    "chacha-poly1305.c",
    "chacha-poly1305-meta.c",
    "chacha-set-key.c",
    "chacha-set-nonce.c",
    "ctr.c",
    "ctr16.c",
    "des.c",
    "des3.c",
    "eax.c",
    "eax-aes128.c",
    "eax-aes128-meta.c",
    "ghash-set-key.c",
    "ghash-update.c",
    "siv-ghash-set-key.c",
    "siv-ghash-update.c",
    "gcm.c",
    "gcm-aes128.c",
    "gcm-aes128-meta.c",
    "gcm-aes192.c",
    "gcm-aes192-meta.c",
    "gcm-aes256.c",
    "gcm-aes256-meta.c",
    "gcm-camellia128.c",
    "gcm-camellia128-meta.c",
    "gcm-camellia256.c",
    "gcm-camellia256-meta.c",
    "gcm-sm4.c",
    "gcm-sm4-meta.c",
    "cmac.c",
    "cmac64.c",
    "cmac-aes128.c",
    "cmac-aes256.c",
    "cmac-des3.c",
    "cmac-aes128-meta.c",
    "cmac-aes256-meta.c",
    "cmac-des3-meta.c",
    "gost28147.c",
    "gosthash94.c",
    "gosthash94-meta.c",
    "hmac-internal.c",
    "hmac-gosthash94.c",
    "hmac-md5.c",
    "hmac-ripemd160.c",
    "hmac-sha1.c",
    "hmac-sha224.c",
    "hmac-sha256.c",
    "hmac-sha384.c",
    "hmac-sha512.c",
    "hmac-streebog.c",
    "hmac-sm3.c",
    "hmac-md5-meta.c",
    "hmac-ripemd160-meta.c",
    "hmac-sha1-meta.c",
    "hmac-sha224-meta.c",
    "hmac-sha256-meta.c",
    "hmac-sha384-meta.c",
    "hmac-sha512-meta.c",
    "hmac-gosthash94-meta.c",
    "hmac-streebog-meta.c",
    "hmac-sm3-meta.c",
    "knuth-lfib.c",
    "hkdf.c",
    "md2.c",
    "md2-meta.c",
    "md4.c",
    "md4-meta.c",
    "md5.c",
    "md5-meta.c",
    "memeql-sec.c",
    "memxor.c",
    "memxor3.c",
    "nettle-lookup-hash.c",
    "nettle-meta-aeads.c",
    "nettle-meta-ciphers.c",
    "nettle-meta-hashes.c",
    "nettle-meta-macs.c",
    "ocb.c",
    "ocb-aes128.c",
    "pbkdf2.c",
    "pbkdf2-hmac-gosthash94.c",
    "pbkdf2-hmac-sha1.c",
    "pbkdf2-hmac-sha256.c",
    "pbkdf2-hmac-sha384.c",
    "pbkdf2-hmac-sha512.c",
    "poly1305-aes.c",
    "poly1305-internal.c",
    "poly1305-update.c",
    "realloc.c",
    "ripemd160.c",
    "ripemd160-compress.c",
    "ripemd160-meta.c",
    "salsa20-core-internal.c",
    "salsa20-crypt-internal.c",
    "salsa20-crypt.c",
    "salsa20r12-crypt.c",
    "salsa20-set-key.c",
    "salsa20-set-nonce.c",
    "salsa20-128-set-key.c",
    "salsa20-256-set-key.c",
    "sha1.c",
    "sha1-compress.c",
    "sha1-meta.c",
    "sha256.c",
    "sha256-compress-n.c",
    "sha224-meta.c",
    "sha256-meta.c",
    "sha512.c",
    "sha512-compress.c",
    "sha384-meta.c",
    "sha512-meta.c",
    "sha512-224-meta.c",
    "sha512-256-meta.c",
    "sha3.c",
    "sha3-permute.c",
    "sha3-224.c",
    "sha3-224-meta.c",
    "sha3-256.c",
    "sha3-256-meta.c",
    "sha3-384.c",
    "sha3-384-meta.c",
    "sha3-512.c",
    "sha3-512-meta.c",
    "sha3-shake.c",
    "shake128.c",
    "shake256.c",
    "sm3.c",
    "sm3-meta.c",
    "serpent-set-key.c",
    "serpent-encrypt.c",
    "serpent-decrypt.c",
    "serpent-meta.c",
    "streebog.c",
    "streebog-meta.c",
    "twofish.c",
    "twofish-meta.c",
    "sm4.c",
    "sm4-meta.c",
    "umac-nh.c",
    "umac-nh-n.c",
    "umac-l2.c",
    "umac-l3.c",
    "umac-poly64.c",
    "umac-poly128.c",
    "umac-set-key.c",
    "umac32.c",
    "umac64.c",
    "umac96.c",
    "umac128.c",
    "version.c",
    "write-be32.c",
    "write-le32.c",
    "write-le64.c",
    "yarrow256.c",
    "yarrow_key_event.c",
    "xts.c",
    "xts-aes128.c",
    "xts-aes256.c",
    "drbg-ctr-aes256.c",
    "slh-shake.c",
    "slh-sha256.c",
    "slh-fors.c",
    "slh-merkle.c",
    "slh-wots.c",
    "slh-xmss.c",
    "slh-dsa.c",
    "slh-dsa-128s.c",
    "slh-dsa-128f.c",
    "slh-dsa-shake-128s.c",
    "slh-dsa-shake-128f.c",
    "slh-dsa-sha2-128s.c",
    "slh-dsa-sha2-128f.c",
    "sntrup761.c",
    "sntrup761-keygen.c",
    "sntrup761-decap.c",
    "sntrup761-encap.c",
    "ml-kem.c",
    "ml-kem-768.c",
    "ml-kem-1024.c",
    "ml-kem-internal.c",
};

// Root-level public headers (see the header-install loop below for
// why this is a static list rather than a directory scan).
const nettle_headers = [_][]const u8{
    "aes-internal.h",
    "aes.h",
    "arcfour.h",
    "arctwo.h",
    "asn1.h",
    "balloon.h",
    "base16.h",
    "base64.h",
    "bignum.h",
    "block-internal.h",
    "blowfish-internal.h",
    "blowfish.h",
    "bswap-internal.h",
    "buffer.h",
    "camellia-internal.h",
    "camellia.h",
    "cast128_sboxes.h",
    "cast128.h",
    "cbc.h",
    "ccm.h",
    "cfb.h",
    "chacha-internal.h",
    "chacha-poly1305.h",
    "chacha.h",
    "cmac.h",
    "ctr-internal.h",
    "ctr.h",
    "curve25519.h",
    "curve448.h",
    "des.h",
    "desCode.h",
    "desinfo.h",
    "drbg-ctr.h",
    "dsa-internal.h",
    "dsa.h",
    "eax.h",
    "ecc-curve.h",
    "ecc-internal.h",
    "ecc.h",
    "ecdsa.h",
    "eddsa-internal.h",
    "eddsa.h",
    "fat-setup.h",
    "gcm-internal.h",
    "gcm.h",
    "getopt.h",
    "ghash-internal.h",
    "gmp-glue.h",
    "gost28147-internal.h",
    "gostdsa.h",
    "gosthash94.h",
    "hkdf.h",
    "hmac-internal.h",
    "hmac.h",
    "hogweed-internal.h",
    "keymap.h",
    "knuth-lfib.h",
    "macros.h",
    "md-internal.h",
    "md2.h",
    "md4.h",
    "md5.h",
    "memops.h",
    "memxor-internal.h",
    "memxor.h",
    "mini-gmp.h",
    "ml-kem-internal.h",
    "ml-kem.h",
    "nettle-internal.h",
    "nettle-meta.h",
    "nettle-types.h",
    "nettle-write.h",
    "nist-keywrap.h",
    "non-nettle.h",
    "oaep.h",
    "ocb.h",
    "pbkdf2.h",
    "pkcs1-internal.h",
    "pkcs1.h",
    "poly1305-internal.h",
    "poly1305.h",
    "pss-mgf1.h",
    "pss.h",
    "realloc.h",
    "ripemd160-internal.h",
    "ripemd160.h",
    "rotors.h",
    "rsa-internal.h",
    "rsa.h",
    "salsa20-internal.h",
    "salsa20.h",
    "serpent-internal.h",
    "serpent.h",
    "sexp.h",
    "sha1.h",
    "sha2-internal.h",
    "sha2.h",
    "sha3-internal.h",
    "sha3.h",
    "siv-cmac.h",
    "siv-gcm.h",
    "slh-dsa-internal.h",
    "slh-dsa.h",
    "sm3.h",
    "sm4.h",
    "sntrup-internal.h",
    "sntrup.h",
    "sntrup761-encoding.h",
    "streebog.h",
    "twofish.h",
    "umac-internal.h",
    "umac.h",
    "xts.h",
    "yarrow.h",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const write_files = b.addWriteFiles();

    // Hand-written stand-in for nettle's autoconf-generated config.h.
    // Grepping nettle_sources's own *.c/*.h files for HAVE_/WORDS_
    // macros shows the only ones actually referenced by the portable
    // (non-asm) code paths built here are HAVE_BUILTIN_BSWAP64 (clang
    // supports it on every target) and WORDS_BIGENDIAN, which is safe
    // to simply leave undefined on any little-endian target (checked
    // with #if, not #ifdef, so an undefined macro already reads as 0 =
    // "not big endian"). Everything else (HAVE_NATIVE_*, HAVE_ELF_AUX_INFO,
    // ...) only gates the asm-optimized/fat-build paths this build.zig
    // doesn't use.
    _ = write_files.add("config.h",
        \\#ifndef NETTLE_CONFIG_H
        \\#define NETTLE_CONFIG_H
        \\
        \\#define HAVE_BUILTIN_BSWAP64 1
        \\
        \\// autoconf-detected __attribute__ support wrappers (see
        \\// aclocal.m4's AX_ macros); zig cc (clang) supports both natively.
        \\#define NONSTRING __attribute__ ((__nonstring__))
        \\#define UNUSED __attribute__ ((__unused__))
        \\
        \\#endif
        \\
    );

    // Stand-in for version.h, normally generated from version.h.in by
    // configure using configure.ac's AC_INIT([nettle], [4.0], ...).
    // NETTLE_USE_MINI_GMP is 0 since hogweed (the only consumer of
    // mini-gmp/GMP_NUMB_BITS) isn't built here.
    _ = write_files.add("version.h",
        \\#ifndef NETTLE_VERSION_H_INCLUDED
        \\#define NETTLE_VERSION_H_INCLUDED
        \\
        \\#ifdef __cplusplus
        \\extern "C" {
        \\#endif
        \\
        \\#define NETTLE_VERSION_MAJOR 4
        \\#define NETTLE_VERSION_MINOR 0
        \\
        \\#define NETTLE_USE_MINI_GMP 0
        \\
        \\int nettle_version_major (void);
        \\int nettle_version_minor (void);
        \\
        \\#ifdef __cplusplus
        \\}
        \\#endif
        \\
        \\#endif /* NETTLE_VERSION_H_INCLUDED */
        \\
    );

    const generated_headers = write_files.getDirectory();

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    mod.addIncludePath(generated_headers);
    mod.addIncludePath(b.path("."));
    mod.addCMacro("HAVE_CONFIG_H", "1");

    mod.addCSourceFiles(.{
        .root = b.path("."),
        .files = &nettle_sources,
        .flags = &.{ "-std=gnu99", "-w" },
    });

    const lib = b.addLibrary(.{
        .name = "nettle",
        .linkage = .static,
        .root_module = mod,
    });
    b.installArtifact(lib);

    // Install the public headers (nettle needs many of them, e.g.
    // aes.h/sha2.h/hmac.h/... alongside nettle-meta.h/nettle-types.h) plus
    // the two generated ones above, so zig-out/include is directly usable.
    // Deliberately a static list, not b.installDirectory(source_dir=".",
    // recursive): this repo's root also contains .git/ (a full clone with
    // ~180 branches of history) plus testsuite/, arm/, x86/, powerpc64/,
    // etc. subdirectories; recursively walking all of that made the
    // install step extremely slow (minutes, not seconds). nettle's own
    // headers are all directly in the repo root, so a plain static list
    // (like nettle_sources above) is both simpler and far faster.
    //
    // Installed under an "nettle/" subdirectory (zig-out/include/nettle/
    // aes.h, not zig-out/include/aes.h): real nettle installs headers
    // this way, and consumers (e.g. QEMU's crypto/*-nettle.c) always
    // write `#include <nettle/aes.h>`, not `#include <aes.h>`.
    for (nettle_headers) |name| {
        lib.installHeader(b.path(name), b.fmt("nettle/{s}", .{name}));
    }
    lib.installHeader(generated_headers.join(b.allocator, "config.h") catch @panic("OOM"), "nettle/nettle-config.h");
    lib.installHeader(generated_headers.join(b.allocator, "version.h") catch @panic("OOM"), "nettle/version.h");

    // sha.h was deleted upstream (real, deprecated compatibility header
    // that just includes sha1.h+sha2.h -- see sha-compat.h, its verbatim
    // last content before deletion, commit 52aeaa6b "Delete old and
    // deprecated file sha.h"). Some consumers still assume its presence
    // (e.g. QEMU's crypto/hash-nettle.c does `#include <nettle/sha.h>`),
    // matching what real/packaged nettle builds still commonly ship.
    lib.installHeader(b.path("sha-compat.h"), "nettle/sha.h");
}
