import { readFileSync, statSync } from "fs";
import * as ts from "typescript";
import { glob } from "glob";

type ScopeInfo = {
  type: "default" | "scope" | "base";
  location: string;
  base: string | null;
  full: string;
  scope: string;
};

function location(node: ts.Node, append: string = ":") {
  const sourceFile = node.getSourceFile();
  let { line, character } = sourceFile.getLineAndCharacterOfPosition(
    node.getStart(sourceFile)
  );

  line += 1;
  character += 1;
  const file = sourceFile.fileName;
  const location = `${file}:${line}:${character}`;

  return `${location}${append}`;
}

const callExpressions = ["t", "i18n.t", "i18n.translate"];

function tsKind(node: ts.Node) {
  const keys = Object.keys(ts.SyntaxKind);
  const values = Object.values(ts.SyntaxKind);

  return keys[values.indexOf(node.kind)];
}

function getTranslationScopesFromFile(filePath: string) {
  const scopes: ScopeInfo[] = [];

  const sourceFile = ts.createSourceFile(
    filePath,
    readFileSync(filePath).toString(),
    ts.ScriptTarget.ES2015,
    true
  );

  inspect(sourceFile);

  return scopes;

  function inspect(node: ts.Node) {
    const next = () => {
      ts.forEachChild(node, inspect);
    };

    if (node.kind !== ts.SyntaxKind.CallExpression) {
      return next();
    }

    const expr = node.getChildAt(0).getText();
    const text = JSON.stringify(node.getText(sourceFile));

    if (!callExpressions.includes(expr)) {
      return next();
    }

    const syntaxList = node.getChildAt(2);

    if (!syntaxList.getText().trim()) {
      return next();
    }

    const scopeNode = syntaxList.getChildAt(0) as ts.StringLiteral;
    const optionsNode = syntaxList.getChildAt(2) as ts.ObjectLiteralExpression;

    if (scopeNode.kind !== ts.SyntaxKind.StringLiteral) {
      return next();
    }

    if (
      optionsNode &&
      optionsNode.kind !== ts.SyntaxKind.ObjectLiteralExpression
    ) {
      return next();
    }

    if (!optionsNode) {
      scopes.push({
        type: "scope",
        scope: scopeNode.text,
        base: null,
        full: scopeNode.text,
        location: location(node, ""),
      });
      return next();
    }

    scopes.push(...getScopes(scopeNode, optionsNode));
  }

  function mapProperties(node: ts.ObjectLiteralExpression): {
    name: string;
    value: ts.Node;
  }[] {
    return node.properties.map((p) => ({
      name: (p.name as ts.Identifier).escapedText.toString(),
      value: p.getChildAt(2),
    }));
  }

  function getScopes(
    scopeNode: ts.StringLiteral,
    node: ts.ObjectLiteralExpression
  ): ScopeInfo[] {
    const suffix = scopeNode.text;

    const result: ScopeInfo[] = [];
    const properties = mapProperties(node);

    if (
      properties.length === 0 ||
      !properties.some((p) => p.name === "scope")
    ) {
      result.push({
        type: "scope",
        scope: suffix,
        base: null,
        full: suffix,
        location: location(scopeNode, ""),
      });
    }

    properties.forEach((property) => {
      if (
        property.name === "scope" &&
        property.value.kind === ts.SyntaxKind.StringLiteral
      ) {
        const base = (property.value as ts.StringLiteral).text;

        result.push({
          type: "base",
          scope: suffix,
          base,
          full: `${base}.${suffix}`,
          location: location(scopeNode, ""),
        });
      }

      if (
        property.name === "defaults" &&
        property.value.kind === ts.SyntaxKind.ArrayLiteralExpression
      ) {
        const op = property.value as ts.ArrayLiteralExpression;
        const values = op.getChildAt(1);
        const objects = (
          values
            .getChildren()
            .filter(
              (n) => n.kind === ts.SyntaxKind.ObjectLiteralExpression
            ) as ts.ObjectLiteralExpression[]
        ).map(mapProperties);

        objects.forEach((object) => {
          object.forEach((prop) => {
            if (
              prop.name === "scope" &&
              prop.value.kind === ts.SyntaxKind.StringLiteral
            ) {
              const text = (prop.value as ts.StringLiteral).text;

              result.push({
                type: "default",
                scope: text,
                base: null,
                full: text,
                location: location(prop.value, ""),
              });
            }
          });
        });
      }
    });

    return result;
  }
}

const patterns = (
  process.argv[2] ??
  "!(node_modules)/**/*.js:!(node_modules)/**/*.ts:!(node_modules)/**/*.jsx:!(node_modules)/**/*.tsx"
).split(":");
const files = patterns.flatMap((pattern) => glob.sync(pattern));
const scopes = files
  .filter((filePath) => statSync(filePath).isFile())
  .flatMap((path) => getTranslationScopesFromFile(path));

console.log(JSON.stringify(scopes, null, 2));
