import 'package:flutter/material.dart';

import '../widgets/airlink_credentials.dart';
import '../widgets/angaza_credentials_form.dart';

class CredentialsPage extends StatefulWidget {
  const CredentialsPage({super.key});

  @override
  State<CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends State<CredentialsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    //initialize tab controller
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    //dispose tab controller
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //return two secondary tabs
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text('AirLink'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text('Angaza'),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              AirLinkCredentialsForm(),
              AngazaCredentialsForm(),
            ],
          ),
        ),
      ],
    );
  }

}
