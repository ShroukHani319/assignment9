import 'dart:typed_data';

import 'package:assignment9/root_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userBox = Hive.box('userBox');

  Uint8List? profileImage;

  @override
  void initState() {
    super.initState();

    final savedImage = userBox.get('profileImage');

    if (savedImage != null) {
      profileImage = Uint8List.fromList(
        List<int>.from(savedImage),
      );
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();

      await userBox.put(
        'profileImage',
        bytes.toList(),
      );

      setState(() {
        profileImage = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = userBox.get(
      'email',
      defaultValue: 'No email',
    );

    return Scaffold(
      appBar: AppBar(
        title:  Text('Profile'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          children: [
            const SizedBox(height: 30),

            Stack(
              children: [
                CircleAvatar(
                  radius: 65,

                  backgroundColor: Colors.grey.shade200,

                  backgroundImage: profileImage != null
                      ? MemoryImage(profileImage!)
                      : null,

                  child: profileImage == null
                      ? const Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.grey,
                  )
                      : null,
                ),

                Positioned(
                  bottom: 0,
                  right: 0,

                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xff112641),

                    child: IconButton(
                      padding: EdgeInsets.zero,

                      onPressed: pickImage,

                      icon: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),

              child: Row(
                children: [
                  const Icon(Icons.email_outlined),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),

              child: const Row(
                children: [
                  Icon(Icons.lock_outline),

                  SizedBox(width: 15),

                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        '••••••••',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed: () async {
                  await userBox.clear();

                  if (!mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RootScreen(),
                    ),
                        (route) => false,
                  );
                },

                icon: const Icon(Icons.logout),

                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 17),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}