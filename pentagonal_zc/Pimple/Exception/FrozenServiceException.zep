namespace Pimple\Exception;

use Psr\Container\ContainerExceptionInterface;

/**
 * An attempt to modify a frozen service was made.
 *
 * Class FrozenServiceException
 * @package Pimple\Exception
 */
class FrozenServiceException extends \RuntimeException implements ContainerExceptionInterface
{
    /**
     * @param string id Identifier of the frozen service
     */
    public function __construct(id)
    {
        parent::__construct(
            sprintf(
                "Cannot override frozen service \"%s\".",
                 id
            )
        );
    }
}
