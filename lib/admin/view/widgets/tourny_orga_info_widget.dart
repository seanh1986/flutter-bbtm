// ignore_for_file: must_be_immutable

import 'package:bbnaf/tournament_repository/src/models/tournament_info.dart';
import 'package:flutter/material.dart';

class TournyOrganizerInfoWidget extends StatefulWidget {
  late List<OrganizerInfo> organizers;

  TournyOrganizerInfoWidget({Key? key, required TournamentInfo info})
      : super(key: key) {
    this.organizers = info.organizers;
  }

  @override
  State<TournyOrganizerInfoWidget> createState() {
    return _TournyBasicInfoWidget();
  }

  void updateTournamentInfo(TournamentInfo info) {
    // Remove empty rows
    organizers.removeWhere((element) =>
        element.email.trim().isEmpty || element.nafName.trim().isEmpty);

    info.organizers = organizers;
  }
}

class _TournyBasicInfoWidget extends State<TournyOrganizerInfoWidget> {
  List<DataColumn> _organizerCols = [];
  List<DataRow> _organizerRows = [];
  late DataTable _orgaDataTable;

  @override
  void initState() {
    super.initState();
    _initOrgas();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text("Organizers", style: TextStyle(fontSize: 18)),
                      Text(
                          "[Primary/Total]: " +
                              widget.organizers
                                  .where((element) => element.primary)
                                  .length
                                  .toString() +
                              " / " +
                              widget.organizers.length.toString(),
                          style: TextStyle(fontSize: 14))
                    ],
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showAddOrgaDialog(context);
                    },
                    child: const Text('Add Organizer'),
                  )
                ],
              ),
              SizedBox(height: 10),
              _buildOrganizerList(),
            ],
          ),
        );
      },
    );
  }

  void _initOrgas() {
    _organizerCols = [
      DataColumn(label: Text("")), // For add/remove rows
      DataColumn(label: Text("Email")),
      DataColumn(label: Text("NafName")),
      DataColumn(label: Text("Primary")),
    ];

    _organizerRows.clear();

    for (int i = 0; i < widget.organizers.length; i++) {
      OrganizerInfo orga = widget.organizers[i];

      TextEditingController emailController =
          TextEditingController(text: orga.email);
      TextFormField emailForm = TextFormField(
          controller: emailController,
          onChanged: (value) => {orga.email = value});

      TextEditingController nafNameController =
          TextEditingController(text: orga.nafName);
      TextFormField nafNameForm = TextFormField(
          controller: nafNameController,
          onChanged: (value) {
            orga.nafName = value;
          });

      Checkbox primaryCheckbox = Checkbox(
        value: orga.primary,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              if (value) {
                widget.organizers.forEach((element) {
                  element.primary = false;
                });
              }
              orga.primary = value;
            });
          }
        },
      );

      ElevatedButton removeOrgaBtn = ElevatedButton(
        onPressed: () {
          setState(() {
            widget.organizers.removeAt(i);
          });
        },
        child: const Text('-'),
      );

      _organizerRows.add(DataRow(cells: [
        DataCell(removeOrgaBtn),
        DataCell(emailForm),
        DataCell(nafNameForm),
        DataCell(primaryCheckbox),
      ]));
    }

    _orgaDataTable = DataTable(
      columns: _organizerCols,
      rows: _organizerRows,
    );
  }

  Widget _buildOrganizerList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.organizers.length,
      itemBuilder: (context, index) {
        OrganizerInfo orga = widget.organizers[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextFormField(
                  initialValue: orga.email,
                  decoration: InputDecoration(labelText: "Email"),
                  onChanged: (value) {
                    setState(() {
                      orga.email = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: orga.nafName,
                  decoration: InputDecoration(labelText: "NafName"),
                  onChanged: (value) {
                    setState(() {
                      orga.nafName = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Primary"),
                    Checkbox(
                      value: orga.primary,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            if (value) {
                              widget.organizers.forEach((element) {
                                element.primary = false;
                              });
                            }
                            orga.primary = value;
                          });
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.organizers.removeAt(index);
                        });
                      },
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddOrgaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String email = "";
        String nafName = "";
        bool primary = false;

        return AlertDialog(
          title: Text("Add Organizer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (value) {
                  email = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "NafName"),
                onChanged: (value) {
                  nafName = value;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Primary"),
                  Checkbox(
                    value: primary,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          primary = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.organizers.add(OrganizerInfo(email, nafName, primary));
                });
                Navigator.of(context).pop();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
