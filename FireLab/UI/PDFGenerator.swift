//
//  PDFGenerator.swift
//  FireLab
//
//  Created by YIHAN  on 12/10/2025.
//

import UIKit

///Render plain text as a single-page PDF in A4 size
enum PDFGenerator {
    static func makePDF(from text: String) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) 
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        return renderer.pdfData { ctx in
            ctx.beginPage()
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byWordWrapping
            paragraph.alignment = .left

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                .paragraphStyle: paragraph
            ]
            (text as NSString).draw(in: pageRect.insetBy(dx: 24, dy: 24), withAttributes: attrs)
        }
    }
}
