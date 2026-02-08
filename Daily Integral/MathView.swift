import SwiftUI
import WebKit

struct MathView: UIViewRepresentable {
    let latex: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        // Gör bakgrunden genomskinlig
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
            <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
            <style>
                body { 
                    display: flex; 
                    justify-content: center; 
                    align-items: center; 
                    height: 100vh; 
                    margin: 0;
                    font-size: 28px;
                    color: black;
                }
            </style>
        </head>
        <body>
            \\[ \(latex) \\]
        </body>
        </html>
        """
        uiView.loadHTMLString(html, baseURL: nil)
    }
}
