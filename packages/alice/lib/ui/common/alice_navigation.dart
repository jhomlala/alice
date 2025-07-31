import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/call_details/page/alice_call_details_page.dart';
import 'package:alice/ui/calls_list/page/alice_calls_list_page.dart';
import 'package:alice/ui/stats/alice_stats_page.dart';
import 'package:flutter/material.dart';

/// Simple navigation helper class for Alice.
class AliceNavigation {
  /// Navigates to calls list page.
  static Future<void> navigateToCallsList({required AliceCore core}) {
    return _navigateToPage(core: core, child: AliceCallsListPage(core: core));
  }

  /// Navigates to call details page.
  static Future<void> navigateToCallDetails({
    required AliceHttpCall call,
    required AliceCore core,
  }) {
    return _navigateToPage(
      core: core,
      child: AliceCallDetailsPage(call: call, core: core),
    );
  }

  /// Navigates to stats page.
  static Future<void> navigateToStats({required AliceCore core}) {
    return _navigateToPage(core: core, child: AliceStatsPage(core));
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
