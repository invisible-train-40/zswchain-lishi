#include <eosio/chain/authority.hpp>

namespace fc {
   void to_variant(const eosio::chain::shared_public_key& var, fc::variant& vo) {
      vo = (std::string)var;
   }
} // namespace fc
