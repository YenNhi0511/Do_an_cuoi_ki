import 'package:flutter_test/flutter_test.dart';
import 'package:do_an_cuoi_ki/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('Task fromJson should parse backend response correctly', () {
      // Giống response từ backend
      final json = {
        '_id': '6916e061137df52beb540b38',
        'title': 'Test Task',
        'description': 'Test Description',
        'category': 'Work',
        'priority': 'Cao',
        'status': 'not started',
        'deadline': '2025-11-15T00:00:00.000Z',
        'startTime': '09:00',
        'endTime': '10:00',
        'isAllDay': false,
        'repeatType': 'none',
        'reminders': ['15 phút trước'],
        'color': '#14B8A6',
        'location': 'Office',
        'url': 'https://example.com',
        'creator': '6916e05f137df52beb540b35', // Backend trả về như này
        'group': null,
        'assignedUsers': ['6916e05f137df52beb540b35'],
        'tags': ['urgent', 'work'],
        'attachments': [],
      };

      final task = Task.fromJson(json);

      expect(task.id, '6916e061137df52beb540b38');
      expect(task.title, 'Test Task');
      expect(task.startTime, '09:00');
      expect(task.endTime, '10:00');
      expect(task.isAllDay, false);
      expect(task.color, '#14B8A6');
      expect(
          task.creatorId, '6916e05f137df52beb540b35'); // Phải map từ 'creator'
      expect(task.assignedUsers, ['6916e05f137df52beb540b35']);
    });

    test('Task fromJson should handle populated creator', () {
      final json = {
        '_id': '123',
        'title': 'Test',
        'description': '',
        'category': 'Work',
        'priority': 'Cao',
        'status': 'not started',
        'creator': {
          '_id': 'user123',
          'name': 'John Doe',
          'email': 'john@example.com'
        }, // Populated object
      };

      final task = Task.fromJson(json);
      expect(task.creatorId, 'user123'); // Phải extract _id từ object
    });

    test('Task toJson should send correct format to backend', () {
      final task = Task(
        title: 'New Task',
        description: 'Description',
        category: 'Work',
        priority: 'Cao',
        status: 'not started',
        startTime: '09:00',
        endTime: '10:00',
        isAllDay: false,
        color: '#FF5733',
        groupId: 'group123', // Flutter dùng groupId
        creatorId: 'user123', // Flutter dùng creatorId
      );

      final json = task.toJson();

      expect(json['title'], 'New Task');
      expect(json['startTime'], '09:00');
      expect(json['endTime'], '10:00');
      expect(json['isAllDay'], false);
      expect(json['color'], '#FF5733');
      expect(json['group'], 'group123'); // Phải convert thành 'group'
      expect(json['creator'], 'user123'); // Phải convert thành 'creator'
      expect(json.containsKey('groupId'), false); // Không gửi groupId
      expect(json.containsKey('creatorId'), false); // Không gửi creatorId
    });

    test('Task helper methods should work correctly', () {
      final task = Task(
        title: 'Test',
        description: '',
        category: 'Work',
        priority: 'Cao',
        status: 'not started',
        startTime: '09:30',
        endTime: '11:45',
      );

      expect(task.startHour, 9.5); // 9:30 = 9.5
      expect(task.endHour, 11.75); // 11:45 = 11.75
      expect(task.duration, 2.25); // 2h 15m
    });
  });
}
