// ignore_for_file: implementation_imports, depend_on_referenced_packages
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mangayomi/providers/storage_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mangayomi/models/model_manga.dart';
import 'package:mangayomi/providers/hive_provider.dart';
import 'package:mangayomi/views/manga/download/model/download_model.dart';
import 'package:mangayomi/views/manga/download/providers/download_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'download_page_widget.g.dart';

@riverpod
class ChapterPageDownloads extends _$ChapterPageDownloads {
  @override
  Widget build(
      {required ModelManga modelManga,
      required int chapterIndex,
      required int chapterId,
      required ModelChapters chapters}) {
    return ChapterPageDownload(
      chapterId: chapterId,
      chapterIndex: chapterIndex,
      modelManga: modelManga,
      chapters: chapters,
    );
  }
}

class ChapterPageDownload extends ConsumerStatefulWidget {
  final ModelManga modelManga;
  final ModelChapters chapters;
  final int chapterId;
  final int chapterIndex;
  const ChapterPageDownload(
      {super.key,
      required this.chapters,
      required this.modelManga,
      required this.chapterId,
      required this.chapterIndex});

  @override
  ConsumerState createState() => _ChapterPageDownloadState();
}

class _ChapterPageDownloadState extends ConsumerState<ChapterPageDownload>
    with AutomaticKeepAliveClientMixin<ChapterPageDownload> {
  List _urll = [];

  final StorageProvider _storageProvider = StorageProvider();
  _startDownload() async {
    final data = await ref.watch(downloadChapterProvider(
            modelManga: widget.modelManga,
            chapterId: widget.chapterId,
            chapterIndex: widget.chapterIndex,
            chapters: widget.chapters)
        .future);
    if (mounted) {
      setState(() {
        _urll = data;
      });
    }
  }

  _deleteFile(List pageUrl) async {
    final path = await _storageProvider.getMangaChapterDirectory(
        widget.modelManga, widget.chapterIndex);

    try {
      path!.deleteSync(recursive: true);
      ref.watch(hiveBoxMangaDownloadsProvider).delete(
            widget.chapters.name!,
          );
    } catch (e) {
      ref.watch(hiveBoxMangaDownloadsProvider).delete(
            widget.chapters.name!,
          );
    }
  }

  bool _isStarted = false;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: 41,
      width: 35,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: ValueListenableBuilder<Box<DownloadModel>>(
          valueListenable:
              ref.watch(hiveBoxMangaDownloadsProvider).listenable(),
          builder: (context, val, child) {
            final entries = val.values
                .where((element) =>
                    "${element.mangaId}/${element.chapterId}" ==
                    "${widget.modelManga.id}/${widget.chapterId}")
                .toList();

            if (entries.isNotEmpty) {
              return entries.first.isDownload
                  ? PopupMenuButton(
                      child: Icon(
                        size: 25,
                        Icons.check_circle,
                        color:
                            Theme.of(context).iconTheme.color!.withOpacity(0.7),
                      ),
                      onSelected: (value) {
                        if (value.toString() == 'Delete') {
                          setState(() {
                            _isStarted = false;
                          });
                          _deleteFile(entries.first.taskIds);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'Send', child: Text("Send")),
                        const PopupMenuItem(
                            value: 'Delete', child: Text('Delete')),
                      ],
                    )
                  : entries.first.isStartDownload &&
                          entries.first.succeeded == 0
                      ? SizedBox(
                          height: 41,
                          width: 35,
                          child: PopupMenuButton(
                            child: _downloadWidget(context, true),
                            onSelected: (value) {
                              if (value.toString() == 'Cancel') {
                                _cancelTasks();
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: 'Cancel', child: Text("Cancel")),
                            ],
                          ))
                      : entries.first.succeeded != 0
                          ? SizedBox(
                              height: 41,
                              width: 35,
                              child: PopupMenuButton(
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: TweenAnimationBuilder<double>(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        tween: Tween<double>(
                                          begin: 0,
                                          end: (entries.first.succeeded /
                                              entries.first.total),
                                        ),
                                        builder: (context, value, _) =>
                                            SizedBox(
                                          height: 2,
                                          width: 2,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 19,
                                            value: value,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color!
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.arrow_downward_sharp,
                                          color: (entries.first.succeeded /
                                                      entries.first.total) >
                                                  0.5
                                              ? Theme.of(context)
                                                  .scaffoldBackgroundColor
                                              : Theme.of(context)
                                                  .iconTheme
                                                  .color!
                                                  .withOpacity(0.7),
                                        )),
                                  ],
                                ),
                                onSelected: (value) {
                                  if (value.toString() == 'Cancel') {
                                    _cancelTasks();
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                      value: 'Cancel', child: Text("Cancel")),
                                ],
                              ))
                          : entries.first.succeeded == 0
                              ? IconButton(
                                  onPressed: () {
                                    // _startDownload();
                                    setState(() {
                                      _isStarted = true;
                                    });
                                  },
                                  icon: Icon(
                                    FontAwesomeIcons.circleDown,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color!
                                        .withOpacity(0.7),
                                    size: 25,
                                  ))
                              : SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: PopupMenuButton(
                                    child: const Icon(
                                      Icons.error_outline_outlined,
                                      color: Colors.red,
                                      size: 25,
                                    ),
                                    onSelected: (value) {
                                      if (value.toString() == 'Retry') {
                                        ref
                                            .watch(
                                                hiveBoxMangaDownloadsProvider)
                                            .delete(
                                              "${widget.modelManga.id}/${widget.chapterId}",
                                            );
                                        _startDownload();
                                        setState(() {
                                          _isStarted = true;
                                        });
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                          value: 'Retry', child: Text("Retry")),
                                    ],
                                  ));
            }
            return _isStarted
                ? SizedBox(
                    height: 50,
                    width: 50,
                    child: PopupMenuButton(
                      child: _downloadWidget(context, true),
                      onSelected: (value) {
                        if (value.toString() == 'Cancel') {
                          _cancelTasks();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'Cancel', child: Text("Cancel")),
                      ],
                    ))
                : IconButton(
                    splashRadius: 5,
                    iconSize: 17,
                    onPressed: () {
                      _startDownload();
                      setState(() {
                        _isStarted = true;
                      });
                    },
                    icon: _downloadWidget(context, false),
                  );
          },
        ),
      ),
    );
  }

  _cancelTasks() {
    setState(() {
      _isStarted = false;
    });
    List<String> taskIds = [];
    for (var id in _urll) {
      taskIds.add(id);
    }
    FileDownloader().cancelTasksWithIds(taskIds).then((value) async {
      await Future.delayed(const Duration(seconds: 1));
      ref.watch(hiveBoxMangaDownloadsProvider).delete(
            "${widget.modelManga.id}/${widget.chapterId}",
          );
    });
  }

  @override
  bool get wantKeepAlive => true;
}

Widget _downloadWidget(BuildContext context, bool isLoading) {
  return Stack(
    children: [
      Align(
          alignment: Alignment.center,
          child: Icon(
            size: 18,
            Icons.arrow_downward_sharp,
            color: Theme.of(context).iconTheme.color!.withOpacity(0.7),
          )),
      Align(
        alignment: Alignment.center,
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            value: isLoading ? null : 1,
            color: Theme.of(context).iconTheme.color!.withOpacity(0.7),
            strokeWidth: 2,
          ),
        ),
      ),
    ],
  );
}
