import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import '../models/post.dart';
import '../models/todo.dart';
import 'create_post_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _mounted = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        context.read<UserBloc>().add(LoadUserDetails(widget.userId));
      }
    });
  }

  @override
  void dispose() {
    _tabController?.removeListener(() { });
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (context.mounted) {
          context.read<UserBloc>().add(const LoadUsers());
        }
        Navigator.of(context).pop();
        return false;
      },
      child: DefaultTabController(
        length: 3,
        animationDuration: const Duration(milliseconds: 300),
        initialIndex: 0,
        child: Builder(
          builder: (BuildContext context) {
            if (_tabController == null) {
              _tabController = DefaultTabController.of(context);
              _tabController?.addListener(() {
                // Only call setState if the widget is still mounted
                if (_mounted) setState(() {});
              });
            }
            
            return Scaffold(
              body: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserInitial || state is UserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is UserError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Theme.of(context).colorScheme.error.withOpacity(0.8),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              if (_mounted) {
                                context.read<UserBloc>().add(LoadUserDetails(widget.userId));
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is UserDetailsLoaded) {
                    return NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            expandedHeight: 200.0,
                            floating: false,
                            pinned: true,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            elevation: 0,
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white),
                                onPressed: () {
                                  if (_mounted) {
                                    context.read<UserBloc>().add(LoadUserDetails(widget.userId));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Refreshing data...')),
                                    );
                                  }
                                },
                              ),
                            ],
                            flexibleSpace: FlexibleSpaceBar(
                              centerTitle: false,
                              titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                              title: Text(
                                state.user.fullName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              background: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                          Theme.of(context).colorScheme.primary,
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Add a subtle pattern overlay
                                  Opacity(
                                    opacity: 0.05,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('assets/images/pattern.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 60,
                                    left: 16,
                                    child: Hero(
                                      tag: 'user-avatar-${state.user.id}',
                                      child: Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(28),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 15,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(28),
                                          child: CachedNetworkImage(
                                            imageUrl: state.user.image,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.white.withOpacity(0.3),
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: Colors.white.withOpacity(0.3),
                                              child: const Icon(Icons.person, size: 40, color: Colors.white70),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPersistentHeader(
                            delegate: _SliverAppBarDelegate(
                              TabBar(
                                tabs: const [
                                  Tab(icon: Icon(Icons.person), text: 'Profile'),
                                  Tab(icon: Icon(Icons.article), text: 'Posts'),
                                  Tab(icon: Icon(Icons.check_circle), text: 'Todos'),
                                ],
                                indicatorWeight: 3,
                                indicatorSize: TabBarIndicatorSize.label,
                                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                                labelColor: Theme.of(context).colorScheme.primary,
                                unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            pinned: true,
                          ),
                        ];
                      },
                      body: TabBarView(
                        children: [
                          _buildUserInfo(state),
                          _buildPostsList(state.posts),
                          _buildTodosList(state.todos),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('No data available'));
                },
              ),
              floatingActionButton: Builder(
                builder: (BuildContext context) {
                  // Get the current tab index from our controller or DefaultTabController
                  int currentTabIndex = _tabController?.index ?? DefaultTabController.of(context)?.index ?? 0;
                  
                  // Show FAB only on the Posts tab (index 1)
                  if (currentTabIndex == 1) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreatePostScreen(userId: widget.userId),
                            ),
                          ).then((created) {
                            if (_mounted && created == true) {
                              context.read<UserBloc>().add(LoadUserDetails(widget.userId));
                            }
                          });
                        },
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.add, size: 28),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserInfo(UserDetailsLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return RefreshIndicator(
      onRefresh: () async {
        if (_mounted) {
          context.read<UserBloc>().add(LoadUserDetails(widget.userId));
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic info card
            _buildInfoCard(
              title: 'Personal Details',
              icon: Icons.person,
              children: [
                _buildContactItem(
                  icon: Icons.alternate_email,
                  title: 'Username',
                  value: '@${state.user.username}',
                ),
                _buildContactItem(
                  icon: Icons.cake,
                  title: 'Age',
                  value: '${state.user.age} years',
                ),
                _buildContactItem(
                  icon: Icons.person_outline,
                  title: 'Gender',
                  value: state.user.gender,
                ),
                _buildContactItem(
                  icon: Icons.calendar_today,
                  title: 'Birth Date',
                  value: state.user.birthDate,
                ),
                _buildContactItem(
                  icon: Icons.bloodtype,
                  title: 'Blood Group',
                  value: state.user.bloodGroup,
                ),
                _buildContactItem(
                  icon: Icons.height,
                  title: 'Height',
                  value: '${state.user.height} cm',
                ),
                _buildContactItem(
                  icon: Icons.line_weight,
                  title: 'Weight',
                  value: '${state.user.weight} kg',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Contact information
            _buildInfoCard(
              title: 'Contact Information',
              icon: Icons.contact_mail,
              children: [
                _buildContactItem(
                  icon: Icons.email,
                  title: 'Email',
                  value: state.user.email,
                ),
                _buildContactItem(
                  icon: Icons.phone,
                  title: 'Phone',
                  value: state.user.phone,
                ),
                _buildContactItem(
                  icon: Icons.home,
                  title: 'Address',
                  value: '${state.user.address.address}, ${state.user.address.city}, ${state.user.address.state}',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Professional information
            _buildInfoCard(
              title: 'Professional Information',
              icon: Icons.work,
              children: [
                _buildContactItem(
                  icon: Icons.school,
                  title: 'University',
                  value: state.user.university,
                ),
                _buildContactItem(
                  icon: Icons.business,
                  title: 'Company',
                  value: state.user.company.name,
                ),
                _buildContactItem(
                  icon: Icons.category,
                  title: 'Department',
                  value: state.user.company.department,
                ),
                _buildContactItem(
                  icon: Icons.badge,
                  title: 'Title',
                  value: state.user.company.title,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Location
            _buildInfoCard(
              title: 'Location',
              icon: Icons.location_on,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.primary.withOpacity(0.08),
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 48,
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Map view not available',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Coordinates: ${state.user.address.coordinates.lat}, ${state.user.address.coordinates.lng}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 1.5,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList(List<Post> posts) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.article_outlined,
                size: 60,
                color: colorScheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No posts yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                'Tap the + button to create a new post',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 30),
            FilledButton.tonal(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePostScreen(userId: widget.userId),
                  ),
                ).then((created) {
                  if (_mounted && created == true) {
                    context.read<UserBloc>().add(LoadUserDetails(widget.userId));
                  }
                });
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Create Post',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final state = context.read<UserBloc>().state as UserDetailsLoaded;
    final bool hasReachedMax = state.hasReachedMaxPosts;
    
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollEndNotification && 
            scrollInfo.metrics.extentAfter < 200 &&
            !hasReachedMax &&
            _mounted) {
          context.read<UserBloc>().add(
            LoadMoreUserPosts(
              userId: widget.userId,
              skip: posts.length,
            ),
          );
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          if (_mounted) {
            context.read<UserBloc>().add(LoadUserDetails(widget.userId));
          }
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length + (hasReachedMax ? 0 : 1),
          itemBuilder: (context, index) {
            if (index >= posts.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final post = posts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 2.0,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.08),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.article,
                            color: colorScheme.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            post.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.body,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (post.tags.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: post.tags.map((tag) {
                              return Chip(
                                label: Text(
                                  tag,
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: colorScheme.primary.withOpacity(0.08),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildReactionChip(
                              icon: Icons.favorite,
                              count: post.reactions['likes'] ?? 0,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 12),
                            _buildReactionChip(
                              icon: Icons.thumb_down,
                              count: post.reactions['dislike'] ?? 0,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReactionChip({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodosList(List<Todo> todos) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checklist,
                size: 60,
                color: colorScheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No todos yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                'This user has no tasks in their to-do list',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        if (_mounted) {
          context.read<UserBloc>().add(LoadUserDetails(widget.userId));
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 1.2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: todo.completed
                    ? Border.all(color: colorScheme.primary.withOpacity(0.2), width: 1)
                    : null,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: todo.completed
                        ? colorScheme.primary.withOpacity(0.1)
                        : colorScheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: todo.completed
                          ? colorScheme.primary.withOpacity(0.2)
                          : colorScheme.tertiary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      todo.completed ? Icons.check_circle : Icons.circle_outlined,
                      size: 24,
                      color: todo.completed ? colorScheme.primary : colorScheme.tertiary,
                    ),
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    todo.todo,
                    style: TextStyle(
                      decoration: todo.completed ? TextDecoration.lineThrough : null,
                      fontSize: 16,
                      color: todo.completed
                          ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)
                          : null,
                      fontWeight: todo.completed ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          if (shrinkOffset > 0)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 4.0,
            ),
        ],
      ),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
} 