import 'dart:convert';
import 'dart:math';

import 'package:appflowy/core/helpers/url_launcher.dart';
import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/base/string_extension.dart';
import 'package:appflowy/shared/icon_emoji_picker/flowy_icon_emoji_picker.dart';
import 'package:appflowy/shared/icon_emoji_picker/icon.dart';
import 'package:appflowy/shared/icon_emoji_picker/icon_search_bar.dart';
import 'package:appflowy/shared/icon_emoji_picker/recent_icons.dart';
import 'package:appflowy/util/debounce.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/space/space_icon_popup.dart';
import 'package:appflowy_backend/log.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Icon;
import 'package:flutter/services.dart';

import 'colors.dart';
import 'icon_color_picker.dart';

// cache the icon groups to avoid loading them multiple times
List<IconGroup>? kIconGroups;
const _kRecentIconGroupName = 'Recent';

extension IconGroupFilter on List<IconGroup> {
  String? findSvgContent(String key) {
    final values = key.split('/');
    if (values.length != 2) {
      return null;
    }
    final groupName = values[0];
    final iconName = values[1];
    final svgString = kIconGroups
        ?.firstWhereOrNull(
          (group) => group.name == groupName,
        )
        ?.icons
        .firstWhereOrNull(
          (icon) => icon.name == iconName,
        )
        ?.content;
    return svgString;
  }

  (IconGroup, Icon) randomIcon() {
    final random = Random();
    final group = this[random.nextInt(length)];
    final icon = group.icons[random.nextInt(group.icons.length)];
    return (group, icon);
  }
}

Future<List<IconGroup>> loadIconGroups() async {
  if (kIconGroups != null) {
    return kIconGroups!;
  }

  final stopwatch = Stopwatch()..start();
  final jsonString = await rootBundle.loadString('assets/icons/icons.json');
  try {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final iconGroups = json.entries.map(IconGroup.fromMapEntry).toList();
    kIconGroups = iconGroups;
    return iconGroups;
  } catch (e) {
    Log.error('Failed to decode icons.json', e);
    return [];
  } finally {
    stopwatch.stop();
    Log.info('Loaded icon groups in ${stopwatch.elapsedMilliseconds}ms');
  }
}

class FlowyIconPicker extends StatefulWidget {
  const FlowyIconPicker({
    super.key,
    required this.onSelectedIcon,
    required this.enableBackgroundColorSelection,
    this.iconPerLine = 9,
  });

  final bool enableBackgroundColorSelection;
  final ValueChanged<IconsData> onSelectedIcon;
  final int iconPerLine;

  @override
  State<FlowyIconPicker> createState() => _FlowyIconPickerState();
}

class _FlowyIconPickerState extends State<FlowyIconPicker> {
  final List<IconGroup> iconGroups = [];
  bool loaded = false;
  final ValueNotifier<String> keyword = ValueNotifier('');
  final debounce = Debounce(duration: const Duration(milliseconds: 150));

  Future<void> loadIcons() async {
    final localIcons = await loadIconGroups();
    final recentIcons = await RecentIcons.getIcons();
    if (recentIcons.isNotEmpty) {
      iconGroups.add(
        IconGroup(
          name: _kRecentIconGroupName,
          icons: recentIcons.sublist(
            0,
            min(recentIcons.length, widget.iconPerLine),
          ),
        ),
      );
    }
    iconGroups.addAll(localIcons);
    if (mounted) {
      setState(() {
        loaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadIcons();
  }

  @override
  void dispose() {
    keyword.dispose();
    debounce.dispose();
    iconGroups.clear();
    loaded = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: IconSearchBar(
            onRandomTap: () {
              final value = kIconGroups?.randomIcon();
              if (value == null) {
                return;
              }
              final color = generateRandomSpaceColor();
              widget.onSelectedIcon(
                IconsData(
                  value.$1.name,
                  value.$2.content,
                  value.$2.name,
                  color,
                ),
              );
            },
            onKeywordChanged: (keyword) => {
              debounce.call(() {
                this.keyword.value = keyword;
              }),
            },
          ),
        ),
        Expanded(
          child: loaded
              ? _buildIcons(iconGroups)
              : const Center(
                  child: SizedBox.square(
                    dimension: 24.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildIcons(List<IconGroup> iconGroups) {
    return ValueListenableBuilder(
      valueListenable: keyword,
      builder: (_, keyword, __) {
        if (keyword.isNotEmpty) {
          final filteredIconGroups = iconGroups
              .map((iconGroup) => iconGroup.filter(keyword))
              .where((iconGroup) => iconGroup.icons.isNotEmpty)
              .toList();
          return IconPicker(
            iconGroups: filteredIconGroups,
            enableBackgroundColorSelection:
                widget.enableBackgroundColorSelection,
            onSelectedIcon: widget.onSelectedIcon,
            iconPerLine: widget.iconPerLine,
          );
        }
        return IconPicker(
          iconGroups: iconGroups,
          enableBackgroundColorSelection: widget.enableBackgroundColorSelection,
          onSelectedIcon: widget.onSelectedIcon,
          iconPerLine: widget.iconPerLine,
        );
      },
    );
  }
}

class IconsData {
  IconsData(this.groupName, this.iconContent, this.iconName, this.color);

  final String groupName;
  final String iconContent;
  final String iconName;
  final String? color;

  String get iconString => jsonEncode({
        'groupName': groupName,
        'iconContent': iconContent,
        'iconName': iconName,
        if (color != null) 'color': color,
      });

  EmojiIconData toEmojiIconData() => EmojiIconData.icon(this);

  static IconsData fromJson(dynamic json) {
    return IconsData(
      json['groupName'],
      json['iconContent'],
      json['iconName'],
      json['color'],
    );
  }
}

class IconPicker extends StatefulWidget {
  const IconPicker({
    super.key,
    required this.onSelectedIcon,
    required this.enableBackgroundColorSelection,
    required this.iconGroups,
    required this.iconPerLine,
  });

  final List<IconGroup> iconGroups;
  final int iconPerLine;
  final bool enableBackgroundColorSelection;
  final ValueChanged<IconsData> onSelectedIcon;

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  final mutex = PopoverMutex();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.iconGroups.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final iconGroup = widget.iconGroups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlowyText(
              iconGroup.displayName.capitalize(),
              fontSize: 12,
              figmaLineHeight: 18.0,
              color: context.pickerTextColor,
            ),
            const VSpace(4.0),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.iconPerLine,
              ),
              itemCount: iconGroup.icons.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final icon = iconGroup.icons[index];
                return widget.enableBackgroundColorSelection
                    ? _Icon(
                        icon: icon,
                        mutex: mutex,
                        onSelectedColor: (context, color) {
                          widget.onSelectedIcon(
                            IconsData(
                              iconGroup.name,
                              icon.content,
                              icon.name,
                              color,
                            ),
                          );
                          RecentIcons.putIcon(icon);
                          PopoverContainer.of(context).close();
                        },
                      )
                    : _IconNoBackground(
                        icon: icon,
                        onSelectedIcon: () {
                          widget.onSelectedIcon(
                            IconsData(
                              iconGroup.name,
                              icon.content,
                              icon.name,
                              null,
                            ),
                          );
                          RecentIcons.putIcon(icon);
                        },
                      );
              },
            ),
            const VSpace(12.0),
            if (index == widget.iconGroups.length - 1) ...[
              const StreamlinePermit(),
              const VSpace(12.0),
            ],
          ],
        );
      },
    );
  }
}

class _IconNoBackground extends StatelessWidget {
  const _IconNoBackground({
    required this.icon,
    required this.onSelectedIcon,
  });

  final Icon icon;
  final VoidCallback onSelectedIcon;

  @override
  Widget build(BuildContext context) {
    return FlowyTooltip(
      message: icon.displayName,
      preferBelow: false,
      child: FlowyButton(
        useIntrinsicWidth: true,
        onTap: () => onSelectedIcon(),
        margin: const EdgeInsets.all(8.0),
        text: Center(
          child: FlowySvg.string(
            icon.content,
            size: const Size.square(20),
            color: context.pickerIconColor,
            opacity: 0.7,
          ),
        ),
      ),
    );
  }
}

class _Icon extends StatefulWidget {
  const _Icon({
    required this.icon,
    required this.mutex,
    required this.onSelectedColor,
  });

  final Icon icon;
  final PopoverMutex mutex;
  final void Function(BuildContext context, String color) onSelectedColor;

  @override
  State<_Icon> createState() => _IconState();
}

class _IconState extends State<_Icon> {
  final PopoverController _popoverController = PopoverController();

  @override
  Widget build(BuildContext context) {
    return AppFlowyPopover(
      direction: PopoverDirection.bottomWithCenterAligned,
      offset: const Offset(0, 6),
      mutex: widget.mutex,
      child: _IconNoBackground(
        icon: widget.icon,
        onSelectedIcon: () => _popoverController.show(),
      ),
      popupBuilder: (context) {
        return Container(
          padding: const EdgeInsets.all(6.0),
          child: IconColorPicker(
            onSelected: (color) => widget.onSelectedColor(context, color),
          ),
        );
      },
    );
  }
}

class StreamlinePermit extends StatelessWidget {
  const StreamlinePermit({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Open source icons from Streamline
    final textStyle = TextStyle(
      fontSize: 12.0,
      height: 18.0 / 12.0,
      fontWeight: FontWeight.w500,
      color: context.pickerTextColor,
    );
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${LocaleKeys.emoji_openSourceIconsFrom.tr()} ',
            style: textStyle,
          ),
          TextSpan(
            text: 'Streamline',
            style: textStyle.copyWith(
              decoration: TextDecoration.underline,
              color: Theme.of(context).colorScheme.primary,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                afLaunchUrlString('https://www.streamlinehq.com/');
              },
          ),
        ],
      ),
    );
  }
}
