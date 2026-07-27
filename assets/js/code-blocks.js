/**
 * Mark one-line fenced code blocks so CSS can use Latte (light).
 * Multiline blocks stay Frappé (dark terminal).
 */
(function () {
  function lineCount(text) {
    var t = (text || "").replace(/\s+$/, "").replace(/^\s+/, "");
    if (!t) return 0;
    return t.split("\n").length;
  }

  function classify(root) {
    var blocks = root.querySelectorAll(
      ".post-content .highlighter-rouge, .post-content figure.highlight, .post-content > pre, .page-content .highlighter-rouge, .page-content figure.highlight, .page-content > pre"
    );
    blocks.forEach(function (el) {
      var pre = el.tagName === "PRE" ? el : el.querySelector("pre");
      var text = pre ? pre.textContent : el.textContent;
      if (lineCount(text) <= 1) {
        el.classList.add("code-oneline");
      } else {
        el.classList.remove("code-oneline");
      }
    });
  }

  function run() {
    classify(document);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", run);
  } else {
    run();
  }
})();
