import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:isar_benchmark/runner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;

import 'result_chart.dart';

class ResultContainer extends StatelessWidget {
  static final GlobalKey globalKey = GlobalKey();

  final String deviceName;
  final List<RunnerResult> results;
  final int objectCount;

  const ResultContainer({
    Key? key,
    required this.deviceName,
    required this.results,
    required this.objectCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RepaintBoundary(
      key: globalKey,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.onSecondary,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              results.first.benchmark.name,
              style: theme.textTheme.headline6,
            ),
            Text(
              '$objectCount Objects on $deviceName',
              style:
                  theme.textTheme.subtitle2!.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ResultChart(results: results),
            ),
          ],
        ),
      ),
    );
  }

  static void shareAsImage() async {
    final boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3);
    final directory = (await getTemporaryDirectory()).path;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    final imgFile = File('$directory/photo.png');
    imgFile.writeAsBytes(pngBytes);
    await Share.shareFiles([imgFile.path]);
  }
}
