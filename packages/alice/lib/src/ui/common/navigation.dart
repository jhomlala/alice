import 'package:alice/src/core/alice_core.dart';
import 'package:alice/src/model/alice_http_call.dart';
import 'package:alice/src/ui/call_details/page/call_details_page.dart';
import 'package:alice/src/ui/calls_list/page/calls_list_page.dart';
import 'package:alice/src/ui/stats/stats_page.dart';
import 'package:material_ui/material_ui.dart';

/// Simple navigation helper class for Alice.
class Navigation {
  /// Navigates to calls list page.
  static Future<void> navigateToCallsList({required AliceCore core}) {
    return _navigateToPage(core: core, child: CallsListPage(core: core));
  }

  /// Navigates to call details page.
  static Future<void> navigateToCallDetails({
    required AliceHttpCall call,
    required AliceCore core,
  }) {
    return _navigateToPage(
      core: core,
      child: CallDetailsPage(call: call, core: core),
    );
  }

  /// Navigates to stats page.
  static Future<void> navigateToStats({required AliceCore core}) {
    return _navigateToPage(core: core, child: StatsPage(core));
  }

  /// Common helper method which checks whether context is available for
  /// navigation and navigates to a specific page.
  static Future<void> _navigateToPage({
    required AliceCore core,
    required Widget child,
  }) {
    var context = core.getContext();
    if (context == null) {
      throw StateError("Context is null in AliceCore.");
    }
    return Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => child),
    );
  }
}
