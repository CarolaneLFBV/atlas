import SwiftUI

/// All are built on Dynamic Type text styles, so they scale.
extension Font {
    /// Large titles that are not navigation titles (34/41 bold).
    static let atlasScreenTitle = Font.largeTitle.bold()
    /// Documentation page titles (30/36 bold on iPhone).
    static let atlasDocumentTitle = Font.title.bold()
    /// "Overview", "Topics" on a page (22 bold).
    static let atlasSectionTitle = Font.title2.bold()
    /// "Featured", "All frameworks" on screens (20 semibold).
    static let atlasSectionHeading = Font.title3.weight(.semibold)
    /// Title of the featured hero card (26 bold).
    static let atlasHeroTitle = Font.title2.bold()
    /// Page abstracts (17/24).
    static let atlasAbstract = Font.body
    /// Documentation prose (16/24).
    static let atlasBody = Font.callout
    /// Row and card titles (16 semibold).
    static let atlasRowTitle = Font.callout.weight(.semibold)
    /// Row subtitles and supporting text (13).
    static let atlasSecondary = Font.footnote
    /// Metadata (12).
    static let atlasCaption = Font.caption
    /// Uppercase eyebrows ("DECLARATION", "TOP HIT"); apply with `atlasEyebrow()` for case and tracking.
    static let atlasEyebrow = Font.caption2.weight(.semibold)
    /// Declarations and symbol names (SF Mono 14 medium).
    static let atlasDeclaration = Font.system(.callout, design: .monospaced).weight(.medium)
    /// Code blocks (SF Mono 13/20).
    static let atlasCode = Font.system(.footnote, design: .monospaced)
    /// Code spans inside prose (SF Mono, on `fill`).
    static let atlasInlineCode = Font.system(.callout, design: .monospaced)
    /// Symbol counts, availability and file names (SF Mono 12 medium).
    static let atlasMonoMeta = Font.system(.caption, design: .monospaced).weight(.medium)
}
