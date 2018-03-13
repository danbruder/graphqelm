## Why do I get an error when I don't provide an Optional Argument? According to the schema it's optional.

This is very common, if you look at your schema you will probably find that the optional argument is marked as nullable (i.e. it doesn't end with a `!`). And in GraphQL, a nullable argument is exactly what an optional argument is, see http://facebook.github.io/graphql/October2016/#sec-Required-Non-Null-Arguments

> Arguments can be required. Arguments are required if the type of the argument is non‐null. If it is not non‐null, the argument is optional.

But even though the schema lists the argument as optional (i.e. nullable), it's common to throw a runtime error and say that it's invalid. A common reason for this is that you must pass in "one of the following...", so no individual argument is required, but if you don't provide one it will throw a runtime error. Here's an example from the Github API (you can reporduce it yourself by running this query in [the Github Explorer](https://developer.github.com/v4/explorer/)):

![github optional argument error](https://raw.githubusercontent.com/dillonkearns/graphqelm/master/assets/github-optional-arg-error.png)

## Why is the [`OptionalArgument`](http://package.elm-lang.org/packages/dillonkearns/graphqelm/10.0.0/Graphqelm-OptionalArgument) union type used instead of `Maybe`?

An optional argument can be either present, absent, or null, so using a Maybe does not fully capture the GraphQL concept of an optional argument. For example, you could have a mutation that deletes an entry if a null argument is provided, or does nothing if the argument is absent. See [The official GraphQL spec section on null](http://facebook.github.io/graphql/October2016/#sec-Null-Value) for details.

## Where is the best place to store my queries/mutations, at the page/view level or somewhere higher?

My recommendation is to keep them in their own module. I have an example of this with [ElmReposRequest.elm](https://github.com/dillonkearns/graphqelm/blob/master/examples/src/ElmReposRequest.elm).
That query module is consumed by the [GithubComplex.elm](https://github.com/dillonkearns/graphqelm/blob/master/examples/src/GithubComplex.elm#L44-L46) module.


## How and why does Graphqelm change some of the names from my GraphQL schema?
Some GraphQL names are invalid in Elm, and others are not idiomatic and would sound awkard in the context of Elm code.
For example, it is conventional to name a Union's values with all caps in GraphQL, like a union `Episode` with values `NEWHOPE`, `EMPIRE`, `JEDI`. Graphqelm will generate the following union type `type Episode = Empire | Jedi | Newhope`. If you follow the GraphQL naming conventions, Graphqelm will generate nice names that follow Elm naming conventions.

Elm also has to avoid reserved words in the language like, so it would convert a field name like `module` or `import` into `module_` and `import_` (See https://github.com/dillonkearns/graphqelm/pull/41 for more in-depth discussion of this). If you want more details on the normalization behavior you can take a look at [the normalization test suite](https://github.com/dillonkearns/graphqelm/blob/master/tests/Generator/NormalizeTests.elm).

What if you have two names that Graphqelm normalizes to the same thing, like a field called `user` and `User` (which would both turn into `user`? This is possible, but indicates that you are not following GraphQL conventions. Consider using a different naming convention. If you have a compelling reason for your naming, open an issue so we can discuss the normalization strategy.