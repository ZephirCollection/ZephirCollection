namespace FastRoute;

/**
 * Class Route
 * @package FastRoute
 */
class Route
{
    /**
     * @var string
     */
    public httpMethod;

    /**
     * @var string
     */
    public regex;

    /**
     * @var array
     */
    public variables;

    /**
     * @var mixed
     */
    public handler;

    /**
     * Constructs a route (value object).
     *
     * @param string httpMethod
     * @param mixed  handler
     * @param string regex
     * @param array  variables
     */
    public function __construct(string! httpMethod, handler, string! regex, array variables)
    {
        let this->httpMethod = httpMethod;
        let this->handler = handler;
        let this->regex = regex;
        let this->variables = variables;
    }

    /**
     * Tests whether this route matches the given string.
     *
     * @param string str
     * @return bool
     */
    public function matches(string! str) -> bool
    {
        var regex;
        let regex = "~^" . this->regex . "~";
        return (bool) preg_match(regex, str);
    }
}

