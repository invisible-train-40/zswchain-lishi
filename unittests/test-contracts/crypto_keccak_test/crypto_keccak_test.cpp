#include <eosio/eosio.hpp>

extern "C"
{
	struct checksum {
		uint8_t hash[32];
	};
	__attribute__((eosio_wasm_import))
	void keccak(const char*, uint32_t, checksum*);
}

class[[eosio::contract]] crypto_keccak_test : public eosio::contract
{
public:
	using eosio::contract::contract;

   // testing protocol feature linkage
	[[eosio::action]] void sha3() {
		checksum test;
		::keccak("testing", 7, &test);
	}
};
