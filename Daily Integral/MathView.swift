import SwiftUI
import WebKit

struct MathView: UIViewRepresentable {
    let latex: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        // Vi hindrar användaren från att skrolla i den lilla rutan
        webView.scrollView.isScrollEnabled = false
        
        // Ladda den tomma mallen med MathJax-scriptet EN gång
        let htmlTemplate = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
            <style>
                body {
                    font-family: -apple-system, sans-serif;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    margin: 0;
                    background-color: transparent;
                    transition: opacity 0.1s ease-in;
                }
                #math-container {
                    font-size: 1.2em;
                }
            </style>
        </head>
        <body>
            <div id="math-container">\\[ \(latex) \\]</div>
            <script>
                function updateMath(newLatex) {
                    const container = document.getElementById('math-container');
                    // Vi sätter in den nya LaTeX-koden i containern
                    container.innerHTML = "\\\\[ " + newLatex + " \\\\]";
                    // Be MathJax rendera om just den containern
                    MathJax.typesetPromise([container]);
                }
            </script>
        </body>
        </html>
        """
        webView.loadHTMLString(htmlTemplate, baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Istället för att ladda om hela sidan (vilket ger vit blink),
        // kör vi bara JavaScript-funktionen som vi definierade ovan.
        let escapedLatex = latex.replacingOccurrences(of: "\\", with: "\\\\")
        let js = "updateMath('\(escapedLatex)');"
        
        uiView.evaluateJavaScript(js, completionHandler: nil)
    }
}
