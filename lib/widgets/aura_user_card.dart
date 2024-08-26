import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aura/helper/global.dart';
import 'package:aura/models/aura_user.dart';

class AuraUserCard extends StatefulWidget {
  final AuraUser user;
  const AuraUserCard({super.key, required this.user});

  @override
  State<AuraUserCard> createState() => _AuraUserCardState();
}

class _AuraUserCardState extends State<AuraUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {},
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.3),
            child: CachedNetworkImage(
              width: mq.height * 0.055,
              height: mq.height * 0.055,
              imageUrl: widget.user.image,
              errorWidget: (context, url, error) =>
              const CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),
          title: Text(widget.user.name),
          subtitle: Text(
            widget.user.about,
            maxLines: 1,
          ),
          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(color: Colors.tealAccent.shade200, borderRadius: BorderRadius.circular(10)),
          ),
          // trailing: const Text(
          //   '12:00 PM',
          //   style: TextStyle(color: Colors.black54),
          // ),
        ),
      ),
    );
  }
}
