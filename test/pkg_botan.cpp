/* botan 探针：SHA-256 与 CTR(AES-256) 两条确定性路径，输出 FNV 哈希。 */
#include <cstdio>
#include <cstdint>
#include <memory>
#include <vector>
#include <botan/hash.h>
#include <botan/stream_cipher.h>

static unsigned long long fnv1a(const void *buf, size_t n)
{
	const unsigned char *p = (const unsigned char *)buf;
	unsigned long long h = 0xcbf29ce484222325ULL;
	for (size_t i = 0; i < n; i++) { h ^= p[i]; h *= 0x100000001b3ULL; }
	return h;
}

int main(int argc, char **argv)
{
	if (argc < 2) { std::fprintf(stderr, "usage: %s <out.bin>\n", argv[0]); return 2; }
	FILE *f = std::fopen(argv[1], "wb");
	if (!f) { std::perror("fopen"); return 2; }

	std::vector<unsigned char> in(65536);
	for (size_t i = 0; i < in.size(); i++) in[i] = (unsigned char)((i * 31 + i / 7) & 0xff);

	auto sha = Botan::HashFunction::create("SHA-256");
	auto digest = sha->process<std::vector<unsigned char>>(in);
	std::fwrite(digest.data(), 1, digest.size(), f);
	std::printf("sha256 fnv=%016llx\n", fnv1a(digest.data(), digest.size()));

	std::vector<unsigned char> key(32), iv(16);
	for (int i = 0; i < 32; i++) key[i] = (unsigned char)(0x40 + i);
	for (int i = 0; i < 16; i++) iv[i] = (unsigned char)(0x10 + i);
	auto ctr = Botan::StreamCipher::create("CTR(AES-256)");
	ctr->set_key(key);
	ctr->set_iv(iv);
	std::vector<unsigned char> out(in.size());
	ctr->cipher(in.data(), out.data(), in.size());
	std::fwrite(out.data(), 1, out.size(), f);
	std::printf("aesctr n=%zu fnv=%016llx\n", out.size(), fnv1a(out.data(), out.size()));

	std::fclose(f);
	return 0;
}
