#include <iostream>

#include <boost/exception/diagnostic_information.hpp>
#include <boost/filesystem/path.hpp>
#include <boost/program_options.hpp>
#include <chainbase/chainbase.hpp>
#include <eosio/chain/permission_object.hpp>
#include <fc/io/json.hpp>
#include <fc/variant.hpp>
#include <fc/crypto/public_key.hpp>
#include <fc/log/log_message.hpp>

using namespace eosio;
using namespace eosio::chain;

using public_key_type = fc::crypto::public_key;

namespace bpo = boost::program_options;
namespace bfs = boost::filesystem;

using bpo::options_description;
using bpo::variables_map;

using std::cout;
using std::endl;

struct dmeos {
   dmeos()
   {}

   void set_program_options(options_description& cli);
   void initialize(const variables_map& options);

   bool print_permission_object = false;
   bool help = false;
};

static const bfs::path database_path("./dmeos_db");

void on_exit() {
   try {
      bfs::remove(database_path / "shared_memory.bin");
   } catch (const std::exception& e) {
      std::cerr << "Unable to delete chainbase file" << endl;
      std::cerr << e.what() << endl;
   }
}

int main(int argc, char** argv) {
   options_description cli ("dmeos command line options");
   try {
      dmeos app;
      app.set_program_options(cli);

      variables_map vmap;
      bpo::store(bpo::parse_command_line(argc, argv, cli), vmap);
      bpo::notify(vmap);
      if (app.help) {
         cli.print(std::cerr);
         return 0;
      }

      std::atexit(on_exit);

      chainbase::database db(database_path, chainbase::database::read_write, 1024*1024*8, true);
      db.add_index<permission_index>();

      if (app.print_permission_object) {
         auto user_public_key = fc::crypto::public_key(std::string("PUB_WA_7qjMn38M4Q6s8wamMcakZSXLm4vDpHcLqcehnWKb8TJJUMzpEZNw41pTLk6Uhqp7p"));
         auto po = db.create<permission_object>([&](auto& p) {
            p.usage_id     = 0;
            p.parent       = 0;
            p.owner        = N(test);
            p.name         = N(active);
            p.auth         = authority(user_public_key);
         });

         auto via_object = FC_LOG_MESSAGE(debug, "Via permission_object ${obj}", ("obj", po));
         cout << via_object.get_message() << endl;

         authority auth = po.auth;

         auto direct = FC_LOG_MESSAGE(debug, "Direct ${obj}", ("obj", auth));
         cout << direct.get_message() << endl;
         return 0;
      }

      app.initialize(vmap);
      cout << "ERROR No flag provided, nothing to do" << endl;
      cout << endl;

      cli.print(std::cout);
   } catch( const fc::exception& e ) {
      elog( "${e}", ("e", e.to_detail_string()));
      return -1;
   } catch( const boost::exception& e ) {
      elog("${e}", ("e",boost::diagnostic_information(e)));
      return -1;
   } catch( const std::exception& e ) {
      elog("${e}", ("e",e.what()));
      return -1;
   } catch( ... ) {
      elog("unknown exception");
      return -1;
   }

   return 0;
}

void dmeos::set_program_options(options_description& cli)
{
   cli.add_options()
         ("print-permission-object", bpo::bool_switch(&print_permission_object)->default_value(false),
          "Print a deep mind log message of a permission_object element for testing purposes.")

         ("help,h", bpo::bool_switch(&help)->default_value(false), "Print this help message and exit.")
         ;
}

void dmeos::initialize(const variables_map& options) {}
