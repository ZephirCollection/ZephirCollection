namespace Pimple\Exception;

use Psr\Container\NotFoundExceptionInterface;

/**
 * An attempt to perform an operation that requires a service identifier was made.
 *
 * Class InvalidServiceIdentifierException
 * @package Pimple\Exception
 */
class InvalidServiceIdentifierException extends \InvalidArgumentException implements NotFoundExceptionInterface
{
    /**
     * @param string id The invalid identifier
     */
    public function __construct(id)
    {
        parent::__construct(
            sprintf(
                "Identifier \"%s\" does not contain an object definition.",
                id
            )
        );
    }
}
