import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pica_comic/network/htmanga_network/htmanga_main_network.dart';
import 'package:pica_comic/network/htmanga_network/models.dart';
import 'package:pica_comic/views/ht_views/ht_comic_page.dart';
import 'package:pica_comic/views/widgets/comic_tile.dart';
import 'package:get/get.dart';
import 'package:pica_comic/views/widgets/show_message.dart';

class HtComicTile extends ComicTile {
  const HtComicTile({required this.comic, super.key});

  final HtComicBrief comic;

  @override
  String get description => comic.time;

  @override
  void favorite() {
    // TODO: implement favorite
  }

  @override
  Widget get image => CachedNetworkImage(
        imageUrl: comic.image,
        fit: BoxFit.cover,
        placeholder: (context, s) =>
            ColoredBox(color: Theme.of(context).colorScheme.surfaceVariant),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        height: double.infinity,
        filterQuality: FilterQuality.medium,
      );

  @override
  void onTap_() => Get.to(() => HtComicPage(comic), preventDuplicates: false);

  @override
  String get subTitle => "${comic.pages} Pages";

  @override
  String get title => comic.name;
}

class HtComicTileInFavoritePage extends HtComicTile {
  const HtComicTileInFavoritePage(
      {super.key, required super.comic, required this.refresh});

  final void Function() refresh;

  @override
  void onLongTap_() {
    showDialog(
        context: Get.context!,
        builder: (context) => Dialog(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.menu_book_outlined),
                      title: const Text("查看详情"),
                      onTap: onTap_,
                    ),
                    ListTile(
                      leading: const Icon(Icons.bookmark_rounded),
                      title: const Text("取消收藏"),
                      onTap: () async {
                        Get.back();
                        showMessage(context, "正在取消收藏");
                        var res = await HtmangaNetwork()
                            .delFavorite(comic.favoriteId!);
                        if (res.error) {
                          showMessage(Get.context, res.errorMessage.toString());
                        } else {
                          Get.closeCurrentSnackbar();
                          refresh();
                        }
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
            ));
  }

  @override
  void onSecondaryTap_(TapDownDetails details) {
    showMenu(
        context: Get.context!,
        position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy),
        items: [
          PopupMenuItem(
              onTap: () => Future.delayed(
                  const Duration(milliseconds: 200), () => onTap_()),
              child: const Text("查看")),
          PopupMenuItem(
              onTap: () =>
                  Future.delayed(const Duration(milliseconds: 200), () async {
                    showMessage(Get.context, "正在取消收藏");
                    var res =
                        await HtmangaNetwork().delFavorite(comic.favoriteId!);
                    if (res.error) {
                      showMessage(Get.context, res.errorMessage.toString());
                    } else {
                      Get.closeCurrentSnackbar();
                      refresh();
                    }
                  }),
              child: const Text("删除收藏")),
        ]);
  }
}