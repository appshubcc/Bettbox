import 'dart:io';
import 'package:example/finder.dart';
import 'package:path/path.dart' as p;
import 'package:code_forge/code_forge.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/styles/github-dark.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final undoController = UndoRedoController();
  final absFilePath = p.join(Directory.current.path, "lib/example_code.dart");
  CodeForgeController? codeController;

  Future<LspConfig> getLsp() async {
    final absWorkspacePath = p.join(Directory.current.path, "lib");
    final data = await LspStdioConfig.start(
      executable: "dart",
      args: ["language-server", "--protocol=lsp"],
      workspacePath: absWorkspacePath,
      languageId: "dart",
    );
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            codeController?.setGitDiffDecorations(
              addedRanges: [(1, 5), (10, 25)],
              removedRanges: [
                (
                  afterLine: 29,
                  content:
                      'final x = 10;\nfinal y = 20;\nprint("removed line");',
                ),
              ],
            );
            codeController?.scrollToLine(30);
          },
        ),
        body: SafeArea(
          child: FutureBuilder<LspConfig>(
            future: getLsp(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Failed to load LSP: ${snapshot.error.toString()}",
                  ),
                );
              }

              final lspConfig = snapshot.data!;
              if (codeController == null ||
                  codeController!.lspConfig != lspConfig) {
                codeController = CodeForgeController(lspConfig: lspConfig);
              }

              return CodeForge(
                undoController: undoController,
                language: langDart,
                editorTheme: githubDarkTheme,
                controller: codeController,
                textStyle: GoogleFonts.jetBrainsMono(),
                filePath: absFilePath,
                tabSize: 4,
                matchHighlightStyle: const MatchHighlightStyle(
                  currentMatchStyle: TextStyle(
                    backgroundColor: Color(0xFFFFA726),
                  ),
                  otherMatchStyle: TextStyle(
                    backgroundColor: Color(0x55FFFF00),
                  ),
                ),
                finderBuilder: (c, controller) =>
                    FindPanelView(controller: controller),
                customCodeSnippets: [
                  CustomCodeSnippet(
                    label: 'if',
                    value: 'if (condition) {\n  \n}',
                    cursorLocations: {4},
                  ),
                  CustomCodeSnippet(
                    label: 'if-else',
                    value: 'if (condition) {\n  \n} else {\n  \n}',
                    cursorLocations: {18, 31},
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
