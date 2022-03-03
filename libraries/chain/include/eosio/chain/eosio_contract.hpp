#pragma once

#include <eosio/chain/types.hpp>
#include <eosio/chain/contract_types.hpp>

_NMSPCE_EOSIO_ { namespace chain {

   class apply_context;

   /**
    * @defgroup native_action_handlers Native Action Handlers
    */
   ///@{
   void apply_zswhq_newaccount(apply_context&);
   void apply_zswhq_updateauth(apply_context&);
   void apply_zswhq_deleteauth(apply_context&);
   void apply_zswhq_linkauth(apply_context&);
   void apply_zswhq_unlinkauth(apply_context&);

   /*
   void apply_zswhq_postrecovery(apply_context&);
   void apply_zswhq_passrecovery(apply_context&);
   void apply_zswhq_vetorecovery(apply_context&);
   */

   void apply_zswhq_setcode(apply_context&);
   void apply_zswhq_setabi(apply_context&);

   void apply_zswhq_canceldelay(apply_context&);
   ///@}  end action handlers

} } /// _NMSPCE_EOSIO_::chain
