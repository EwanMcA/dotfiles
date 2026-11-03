# Rules

- Never commit or push, unless directly told to do so.
- Code comments should be concise, use simple language, and always quickly describe what something is/does before saying why.
- When adding unit tests we should always ensure that they aren't redundant/already covered elsewhere.
- When adding unit tests we should always ensure that they're testing the layer the module lives in, not a higher/lower layer which should be tested in that area.
  - ie tests which assert the behaviour of a service, should not live in the frontdoor package
