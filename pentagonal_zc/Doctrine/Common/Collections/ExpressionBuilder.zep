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

namespace Doctrine\Common\Collections;

use Doctrine\Common\Collections\Expr\Comparison;
use Doctrine\Common\Collections\Expr\CompositeExpression;
use Doctrine\Common\Collections\Expr\Value;

/**
 * Builder for Expressions in the {@link Selectable} interface.
 *
 * Important Notice for interoperable code: You have to use scalar
 * values only for comparisons, otherwise the behavior of the comparison
 * may be different between implementations (Array vs ORM vs ODM).
 *
 * @author Benjamin Eberlei <kontakt@beberlei.de>
 * @since  2.3
 */
class ExpressionBuilder
{
    /**
     * @param mixed x
     * @return CompositeExpression
     */
    public function andX(x = null) -> <CompositeExpression>
    {
        return new CompositeExpression(CompositeExpression::TYPE_AND, func_get_args());
    }

    /**
     * @param mixed x
     * @return CompositeExpression
     */
    public function orX(x = null) -> <CompositeExpression>
    {
        return new CompositeExpression(CompositeExpression::TYPE_OR, func_get_args());
    }

    /**
     * @param string field
     * @param mixed  value
     *
     * @return Comparison
     */
    public function eq(string! field, value) -> <Comparison>
    {
        return new Comparison(field, Comparison::EQ, new Value(value));
    }

    /**
     * @param string field
     * @param mixed  value
     *
     * @return Comparison
     */
    public function gt(string! field, value) -> <Comparison>
    {
        return new Comparison(field, Comparison::GT, new Value(value));
    }

    /**
     * @param string field
     * @param mixed  value
     *
     * @return Comparison
     */
    public function lt(string! field, value) -> <Comparison>
    {
        return new Comparison(field, Comparison::LT, new Value(value));
    }

    /**
     * @param string field
     * @param mixed  value
     *
     * @return Comparison
     */
    public function gte(string! field, value) -> <Comparison>
    {
        return new Comparison(field, Comparison::GTE, new Value(value));
    }

    /**
     * @param string field
     * @param mixed  value
     *
     * @return Comparison
     */
    public function lte(string! field, value) -> <Comparison>
    {
        return new Comparison(field, Comparison::LTE, new Value(value));
    }

    /**
     * @param string field
     * @param mixed  value
     *
     * @return Comparison
     */
    public function neq(string! field, value) -> <Comparison>
    {
        return new Comparison(field, Comparison::NEQ, new Value(value));
    }

    /**
     * @param string field
     *
     * @return Comparison
     */
    public function isNull(string! field)
    {
        return new Comparison(field, Comparison::EQ, new Value(null));
    }

    /**
     * @param string field
     * @param mixed  values
     *
     * @return Comparison
     */
    public function $in(string! field, array values) -> <Comparison>
    {
        return new Comparison(field, Comparison::$IN, new Value(values));
    }

    /**
     * @param string field
     * @param mixed  values
     *
     * @return Comparison
     */
    public function notIn(string! field, array values) -> <Comparison>
    {
        return new Comparison(field, Comparison::NIN, new Value(values));
    }

    /**
     * @param string field
     * @param mixed  value
     *
     * @return Comparison
     */
    public function contains(string! field, value) -> <Comparison>
    {
        return new Comparison(field, Comparison::CONTAINS, new Value(value));
    }

    /**
     * @param string field
     * @param mixed  value
     *
     * @return Comparison
     */
    public function memberOf (string! field, value) -> <Comparison>
    {
        return new Comparison(field, Comparison::MEMBER_OF, new Value(value));
    }

    /**
     * @param string field
     * @param mixed  value
     *
     * @return Comparison
     */
    public function startsWith(string! field, value) -> <Comparison>
    {
        return new Comparison(field, Comparison::STARTS_WITH, new Value(value));
    }

    /**
     * @param string field
     * @param mixed  value
     *
     * @return Comparison
     */
    public function endsWith(string! field, value) -> <Comparison>
    {
        return new Comparison(field, Comparison::ENDS_WITH, new Value(value));
    }    

}
