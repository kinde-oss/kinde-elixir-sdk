# DEPRECATED - Kinde Elixir SDK

> **⚠️ This SDK is deprecated and this repository has been archived.**
>
> **Effective Date:** November 17, 2025
>
> **Support Ended:** December 31, 2025

Due to low adoption and usage, we decided to deprecate the Kinde Elixir SDK. This allows us to focus our resources on SDKs with higher demand and better serve the broader Kinde community.

## What This Means

- **No new features** will be added to this SDK
- **No bug fixes** will be provided
- **No SDK-specific support or maintenance** will be provided
- The repository is in **read-only mode**

## Migration Options

### Option 1: Use Kinde's API Directly

The Kinde Elixir SDK was a wrapper around our API. You can integrate directly with the [Kinde API](https://kinde.com/api/docs/) using any HTTP client library in Elixir (such as `HTTPoison`, `Req`, or `Finch`).

- [Kinde API Reference](https://kinde.com/api/docs/)
- [Using Kinde without an SDK](https://docs.kinde.com/developer-tools/about/using-kinde-without-an-sdk/)

### Option 2: Community-Maintained Alternatives

If a community member creates an alternative Elixir SDK, we'll link to it here. Check our [developer community](https://kinde.com/community/) for updates.

### Option 3: Use Another Language SDK

If your architecture allows, consider using one of our actively maintained SDKs:

- [Node.js SDK](https://github.com/kinde-oss/kinde-nodejs-sdk)
- [Python SDK](https://github.com/kinde-oss/kinde-python-sdk)
- [Go SDK](https://github.com/kinde-oss/kinde-go)
- [PHP SDK](https://github.com/kinde-oss/kinde-php-sdk)

[View all Kinde SDKs](https://docs.kinde.com/developer-tools/about/our-sdks/)

## For Existing Users

If you're currently using this SDK in production:

- The SDK will continue to function as-is, but we recommend migrating to direct API integration
- Test thoroughly in a development environment before switching in production

## Need Help Migrating?

- **Join our community:** [Kinde Slack Community](https://kinde.com/community/)
- **General Kinde support:** [support@kinde.com](mailto:support@kinde.com)
- **Documentation:** [docs.kinde.com](https://docs.kinde.com/)

---

We appreciate everyone who used and contributed to this SDK. Thank you for being part of the Kinde community.

**— The Kinde Team**

## License

MIT License. See [LICENSE](LICENSE) for details.
