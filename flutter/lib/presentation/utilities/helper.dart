enum SortOrder { asc, desc }

class Helper {
  static List<T> buildTreeRecursive<T>(
    List<T> items, {
    required String Function(T) getId,
    required String? Function(T) getParentId,
    required T Function(T node, List<T> children) copyWithChildren,
    String Function(T)? getSortKey,
    SortOrder sortOrder = SortOrder.asc,
    String? parentId,
  }) {
    final children = items
      .where((item) => getParentId(item) == parentId)
      .map((item) {
        final childNodes = buildTreeRecursive<T>(
          items,
          getId: getId,
          getParentId: getParentId,
          copyWithChildren: copyWithChildren,
          getSortKey: getSortKey,
          sortOrder: sortOrder,
          parentId: getId(item),
        );
        return copyWithChildren(item, childNodes);
      })
      .toList();

    if (getSortKey != null) {
      children.sort((a, b) {
        final cmp = getSortKey(a).compareTo(getSortKey(b));
        return sortOrder == SortOrder.asc ? cmp : -cmp;
      });
    }
    return children;
  }

  static int? getPdfPageFromUrl(String url) {
    final uri = Uri.parse(url);
    final fragment = uri.fragment;

    if (fragment.isEmpty) return null;

    final match = RegExp(r'page=(\d+)').firstMatch(fragment);
    if (match == null) return null;

    return int.tryParse(match.group(1)!);
  }

}