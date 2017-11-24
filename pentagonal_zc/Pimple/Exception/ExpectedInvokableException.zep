namespace Pimple\Exception;

use Psr\Container\ContainerExceptionInterface;

/**
 * A closure or invokable object was expected.
 *
 * Class ExpectedInvokableException
 * @package Pimple\Exception
 */
class ExpectedInvokableException extends \InvalidArgumentException implements ContainerExceptionInterface
{
}
