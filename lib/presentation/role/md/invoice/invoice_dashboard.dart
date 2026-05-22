import 'package:flutter/material.dart';

import 'pending_invoice_page.dart';
import 'approved_invoice_page.dart';
import 'rejected_invoice_page.dart';

class InvoiceDashboard
    extends StatelessWidget {
  const InvoiceDashboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,

      child: Scaffold(
        appBar: AppBar(
          title:
              const Text(
                "Invoice Dashboard",
              ),

          bottom:
              const TabBar(
                tabs: [
                  Tab(
                    text:
                        "Pending",
                  ),

                  Tab(
                    text:
                        "Approved",
                  ),

                  Tab(
                    text:
                        "Rejected",
                  ),
                ],
              ),
        ),

        body:
            const TabBarView(
              children: [
                PendingInvoicePage(),

                ApprovedInvoicePage(),

                RejectedInvoicePage(),
              ],
            ),
      ),
    );
  }
}