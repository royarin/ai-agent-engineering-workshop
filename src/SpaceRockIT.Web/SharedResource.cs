namespace SpaceRockIT.Web;

/// <summary>
/// Marker type for the site's shared UI strings. Views and controllers localize through
/// <c>IHtmlLocalizer&lt;SharedResource&gt;</c> / <c>IStringLocalizer&lt;SharedResource&gt;</c>,
/// which resolve against <c>Resources/SharedResource.{culture}.resx</c>.
/// </summary>
public sealed class SharedResource;
