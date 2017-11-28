/**
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/**
 * PhPass PassWord Hashes Library
 */
namespace Zc;

/**
 * Portable PHP password hashing framework.
 *
 * Version 0.3 / genuine.
 *
 * Written by Solar Designer <solar at openwall.com> in 2004-2006 and placed in
 * the public domain.  Revised in subsequent years, still public domain.
 *
 * There"s absolutely no warranty.
 *
 * The homepage URL for this framework is:
 *
 *   http://www.openwall.com/phpass/
 *
 * Please be sure to update the Version line if you edit this file in any way.
 * It is suggested that you leave the main version number intact, but indicate
 * your project name (after the slash) and add your own revision information.
 *
 * Please do not change the "private" password hashing method implemented in
 * here, thereby making your hashes incompatible.  However, if you must, please
 * change the hashed type identifier (the "$P$") to something different.
 *
 * Obviously, since this code is in the public domain, the above are not
 * requirements (there can be none), but merely suggestions.
 * -------------------------------------------------------------
 *
 * - version 1.0.0 Edited from Original Version <Version 0.3 - Genuine> of PhPass
 *          Complete OOP php5 structural
 *
 * @version 1.0.0
 *
 * Class PasswordHash
 * @package Zc
 * @author pentagonal <org@pentagonal.org>
 *         solar - open wall <solar@openwall.com>
 * @link http://www.openwall.com/phpass/
 * @final
 */
final class PasswordHash
{
    /**
    * Version
    */
    const VERSION = "1.1.0";

    /**
     * @var string
     */
    private ito64 = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

    /**
     * used to cached array for faster result
     * that zephir maybe does not support or invalid string as access offset
     *
     * @var array
     */
    private static ito64Array { get };
    private static itoA64Array { get };

    /**
    * Iterate count
    * @var integer
    */
    private iteration_count_log;

    /**
    * is portable hash
    * @var boolean
    */
    private portable_hashes;

    /**
     * as static selector that random_bytes() function has exists
     *
     * @var bool
     */
    private static randomBytes;

    /**
     * @var string
     */
    private random_state;

    /**
    * PHP 5 Constructor
    *
    * @param integer iterationCountLog iteration count
    * @param boolean $portable_hashes   portable has or no (false recommended)
    */
    public function __construct(int iterationCountLog = 8, bool portable_hashes = false)
    {
        if ! is_bool(self::randomBytes) {
            let self::randomBytes = function_exists("random_bytes");
            let self::ito64Array  = str_split(this->ito64, 1);
            let self::itoA64Array = str_split("./ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", 1);
        }

        if iterationCountLog < 4 || iterationCountLog > 31 {
            let iterationCountLog = 8;
        }

        let this->iteration_count_log = iterationCountLog;
        let this->portable_hashes = portable_hashes;
        let this->random_state = microtime();
        if (function_exists("getmypid")) {
            let this->random_state .= getmypid();
        }
    }

    /**
     * Base 64 Encoded base count iteration
     *
     * @param  string $input string to encode
     * @param  integer $count count iteration
     * @access private internal use only
     * @return string
     */
    private function encode64(string! input, int count) -> string
    {
        var output = "", value;
        int i = 0;
        do {
            let value = ord(substr(input, i, 1));
            let i++;
            let output .= self::ito64Array[value & 0x3f];
            if i < count {
                let value = value | (ord(substr(input, i, 1)) << 8);
            }

            let output .= self::ito64Array[(value >> 6) & 0x3f];
            if i >= count {
                break;
            }
            let i++;
            if i < count {
                let value = value | (ord(substr(input, i, 1)) << 16);
            }

            let output .= self::ito64Array[(value >> 12) & 0x3f];
            if i >= count {
                break;
            }
            let i++;
            let output .= self::ito64Array[(value >> 18) & 0x3f];
        } while (i < count);

        return output;
    }

    /**
     * generate private salt
     *
     * @param  string $input string to be generate salt
     * @access private internal use only
     * @return string
     */
    private function genSaltPrivate(string! input) -> string
    {
        return "$P$" . substr(this->ito64, min(this->iteration_count_log + 5, 30), 1) . this->encode64(input, 6);
    }

    /**
     * Encrypt private password
     *
     * @param  string $password the password
     * @param  string $setting  salt private
     * @access private internal use only
     * @return string
     */
    private function cryptPrivate(string password, string setting) -> string
    {
        var output = "*0";
        if substr(setting, 0, 2) === output {
            let output = "*1";
        }

        var id;
        let id = substr(setting, 0, 3);
        //# We use "$P$", phpBB3 uses "$H$" for the same thing
        if id !== "$P$" && id !== "$H$" {
            return output;
        }

        var count_log = strpos(this->ito64, substr(setting, 3, 1));
        int count;
        var salt;

        if count_log < 7 || count_log > 30 {
            return output;
        }

        let count = (1 << (int)count_log);
        let salt = substr(setting, 4, 8);
        if strlen(salt) != 8 {
            return output;
        }

        var hash;
        /*
        # We're kind of forced to use MD5 here since it's the only
        # cryptographic primitive available in all versions of PHP
        # currently in use.  To implement our own low-level crypto
        # in PHP would result in much worse performance and
        # consequently in lower iteration counts and hashes that are
        # quicker to crack (by non-PHP code).
        */
        let hash = md5(salt . password, true);
        do {
            let hash = md5(hash . password, true);
            let count--;
        } while (count);

        let output  = substr(setting, 0, 12);
        let output .= this->encode64(hash, 16);

        return output;
    }

    /**
     * Generate extended salt string
     *
     * @param  string $input to be generate
     * @access private internal use only
     * @return string
     */
    private function genSaltExtended(string input) -> string
    {
        var count_log = min(this->iteration_count_log + 8, 24);
        /*
        # This should be odd to not reveal weak DES keys, and the
        # maximum valid value is (2**24 - 1) which is odd anyway.
        */
        int count = (1 << (int) count_log) - 1;
        var output = "_";
        let output .= self::ito64Array[count & 0x3f];
        let output .= self::ito64Array[(count >> 6) & 0x3f];
        let output .= self::ito64Array[(count >> 12) & 0x3f];
        let output .= self::ito64Array[(count >> 18) & 0x3f];
        let output .= this->encode64(input, 3);

        return output;
    }

    /**
     * Getting random bytes
     *
     * @param  integer $count count random
     * @access private internal use only
     * @return string
     */
    private function getRandomBytes(int! count) -> string
    {
        if self::randomBytes {
            return random_bytes(count);
        }

        int i = 0;
        var output = "";
        do {
            let i += 16;
            let this->random_state = md5(microtime() . this->random_state);
            let output .= pack('H*', md5(this->random_state));
        } while (i < count);

        return substr(output, 0, count);
    }

    /**
     * generating Salt with blowFish method
     *
     * @param  string $input to generate
     * @access private internal use only
     * @return string
     */
    private function genSaltBlowFish(input) -> string
    {
        /*
        # This one needs to use a different order of characters and a
        # different encoding scheme from the one in encode64() above.
        # We care because the last character in our encoded string will
        # only represent 2 bits.  While two known implementations of
        # bcrypt will happily accept and correct a salt string which
        # has the 4 unused bits set to non-zero, we do not want to take
        # chances and we also do not want to waste an additional byte
        # of entropy.
        */
        // ordinal 0 === 48
        var output;
        let output =
            "$2a$"
            . chr(48 + this->iteration_count_log / 10)
            . chr(48 + this->iteration_count_log % 10)
            . "$";
        var i = 0, c1, c2;
        do {
            let c1 = ord(substr(input, i, 1));
            let i++;
            let output .= self::itoA64Array[c1 >> 2];
            let c1 = (c1 & 0x03) << 4;
            if i >= 16 {
                let output .= self::itoA64Array[c1];
                break;
            }

            let c2 = ord(substr(input, i, 1));
            let i++;
            let c1 = c1 | (c2 >> 4);

            let output .= self::itoA64Array[c1];
            let c1 = (c2 & 0x0f) << 2;
            let c2 = ord(substr(input, i, 1));
            let i++;
            let c1 = c1 | (c2 >> 6);
            let output .= self::itoA64Array[c1];
            let output .= self::itoA64Array[c2 & 0x3f];
        } while (1);

        return $output;
    }

    /**
    * Hash the password
    *
    * @param  string text the password the be random hash
    * @return string hashed password
    */
    public function hash(string text) -> string
    {
        if !is_string(text) {
            throw new \InvalidArgumentException(
                sprintf(
                    "Argument must be as a string %s given",
                    typeof text
                )
            );
        }

        var random = "", hash = "";
        if CRYPT_BLOWFISH === 1 && ! this->portable_hashes {
            let random = this->getRandomBytes(16);
            let hash = crypt(text, this->genSaltBlowFish(random));
            if strlen(hash) === 60 {
                return hash;
            }
        }

        if CRYPT_EXT_DES === 1 && ! this->portable_hashes {
            if strlen(random) < 3 {
                let random = this->getRandomBytes(3);
            }

            let hash = crypt(text, this->genSaltExtended(random));
            if strlen(hash) === 20 {
                return hash;
            }
        }

        if strlen(random) < 6 {
            let random = this->getRandomBytes(6);
        }
        let hash = this->cryptPrivate(text, this->genSaltPrivate(random));
        if strlen(hash) === 34 {
            return hash;
        }

        // # Returning "*" on error is safe here, but would _not_ be safe
        // # in a crypt(3)-like function used _both_ for generating new
        // # hashes and for validating passwords against existing hashes.
        trigger_error(
            sprintf(
                "Can not get safe hashed string for: %1$s",
                text
            ),
            E_USER_WARNING
        );

        return "*";
    }

    /**
    * Checking match password between encrypted and plain password
    *
    * @param  string text plain text password
    * @param  string storedHash    hashed password
    * @return boolean              true if match
    */
    public function verify(string text, string! storedHash) -> bool
    {
        if !is_string(text) || ! is_string(storedHash) {
            return false;
        }

        var hash = this->cryptPrivate(text, storedHash);
        if substr(hash, 0, 1) === "*" {
            let hash = crypt(text, storedHash);
        }

        if hash === storedHash {
            return true;
        }

        return false;
    }

    /**
    * Checking is string maybe hashed by PhPass
    *
    * @param string text has to check
    * @return bool
    */
    public static function isMaybeHashed(text) -> bool
    {
      if (! is_string(text)
          || ! in_array(strlen(text), [20, 34, 60])
          || preg_match(
                "/[^a-zA-Z0-9\.\/\$_]/", /**"/**/
                text
            )
      ) {
          return false;
      }

      switch strlen(text) {
          case 20:
              return substr(text, 0, 1) === "_" && false === strpos(text, "$")
              && strpos(text, ".") !== false;
          case 34:
              return 2 === substr_count(text, "$")
                && in_array(substr(text, 0, 3), ["$P$", "$H$"]);
      }

      return substr(text, 0, 4) === "$2a$"
          && substr(text, 6, 1) === "$"
          && is_numeric(substr(text, 4, 2))
          && substr_count(text, "$") === 3;
    }
}
