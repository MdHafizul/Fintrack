import 'package:flutter/material.dart';
import 'package:expensetracker/service/database.dart';
import 'package:expensetracker/service/authService.dart';
import 'package:expensetracker/pages/chatpage.dart';
import 'package:expensetracker/pages/statisticpage.dart';
import 'package:expensetracker/pages/homepagetest.dart';
import 'package:expensetracker/pages/authentication/loginpage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic> userData = {};
  bool isLoading = true;
  int _selectedIndex = 3; // Set the initial index to 3 for SettingsPage

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> fetchUserData() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId != null) {
        userData = await LocalStorageApi.getUserData(userId);
        setState(() {
          isLoading = false;
        });
        print('User data fetched successfully: $userData');
      } else {
        print('User ID is null');
      }
    } catch (e) {
      print('Failed to fetch user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteUser() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId != null) {
        await LocalStorageApi.deleteUserData(userId);
        print('User deleted successfully');
        // Handle successful deletion
        AuthService.logout();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        print('User ID is null');
      }
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Future<void> updateUser(Map<String, dynamic> updatedData) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId != null) {
        await LocalStorageApi.updateUserData(userId, updatedData);
        setState(() {
          userData = updatedData;
        });
        print('User updated successfully: $userData');
        await fetchUserData(); // Fetch updated data
        showUpdateSuccessDialog();
      } else {
        print('User ID is null');
      }
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  void showUpdateSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Account updated successfully!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showUpdateDialog() {
    final _formKey = GlobalKey<FormState>();
    String username = userData['username'];
    String email = userData['email'];
    String phoneNumber = userData['phoneNumber'];
    String password = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Account'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: username,
                    decoration: InputDecoration(labelText: 'Username'),
                    onChanged: (value) => username = value,
                  ),
                  TextFormField(
                    initialValue: email,
                    decoration: InputDecoration(labelText: 'Email'),
                    onChanged: (value) => email = value,
                  ),
                  TextFormField(
                    initialValue: phoneNumber,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    onChanged: (value) => phoneNumber = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onChanged: (value) => password = value,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20), // Add some padding at the bottom
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  updateUser({
                    'username': username,
                    'email': email,
                    'phoneNumber': phoneNumber,
                    'password': password,
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) async {
    if (index == 0) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Homepagetest()),
      );
      if (result != null) {
        setState(() {
          _selectedIndex = result;
        });
      }
    } else if (index == 1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Chatpage()),
      );
      if (result != null) {
        setState(() {
          _selectedIndex = result;
        });
      }
    } else if (index == 2) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StatisticPage()),
      );
      if (result != null) {
        setState(() {
          _selectedIndex = result;
        });
      }
    } else if (index == 3) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF429690),
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF429690),
                ),
                child: Center(
                  child: Text(
                    'FinTrack',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListTile(
                iconColor: Colors.white,
                leading: const Icon(Icons.home),
                title:
                    const Text('Home', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                iconColor: Colors.white,
                leading: const Icon(Icons.settings),
                title: const Text('Settings',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                iconColor: Colors.white,
                leading: const Icon(Icons.logout),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Image.asset("assets/images/homepagebg.png"),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          return IconButton(
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                            icon: const Icon(Icons.menu),
                            color: Colors.white,
                            iconSize: 28,
                          );
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: AssetImage(
                                      'assets/images/profile.png'), // Replace with actual profile image
                                ),
                                SizedBox(height: 20.0),
                                Text('Username: ${userData['username']}'),
                                Text('Email: ${userData['email']}'),
                                Text(
                                    'Phone Number: ${userData['phoneNumber']}'),
                                SizedBox(height: 20.0),
                                ElevatedButton(
                                  onPressed: showUpdateDialog,
                                  child: Text('Update Account'),
                                ),
                                ElevatedButton(
                                  onPressed: deleteUser,
                                  child: Text('Delete Account'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.white,
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 0),
            _buildNavItem(Icons.chat, 1),
            const SizedBox(width: 40),
            _buildNavItem(Icons.bar_chart, 2),
            _buildNavItem(Icons.settings, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => _onItemTapped(index),
      icon: Icon(icon),
      color: isSelected ? const Color(0xFF429690) : Colors.grey,
      iconSize: isSelected ? 36 : 28,
    );
  }
}
