#!/bin/bash

# Script test nhanh Backend API
# Sử dụng: chmod +x test-api.sh && ./test-api.sh

BASE_URL="http://localhost:5000"
TOKEN=""

echo "🧪 TESTING TASK MANAGER API"
echo "======================================"

# Test 1: Health Check
echo ""
echo "📌 Test 1: Health Check"
curl -s $BASE_URL | jq .
sleep 1

# Test 2: Register
echo ""
echo "📌 Test 2: Register User"
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "123456"
  }')
echo $REGISTER_RESPONSE | jq .
TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.token')
echo "✅ Token: $TOKEN"
sleep 1

# Test 3: Login
echo ""
echo "📌 Test 3: Login"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "123456"
  }')
echo $LOGIN_RESPONSE | jq .
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.token')
sleep 1

# Test 4: Get Profile
echo ""
echo "📌 Test 4: Get Profile"
curl -s "$BASE_URL/api/auth/profile" \
  -H "Authorization: Bearer $TOKEN" | jq .
sleep 1

# Test 5: Create Task
echo ""
echo "📌 Test 5: Create Task"
TASK_RESPONSE=$(curl -s -X POST "$BASE_URL/api/tasks" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Task",
    "description": "This is a test task",
    "category": "Testing",
    "priority": "Cao",
    "deadline": "2025-12-31",
    "status": "not started"
  }')
echo $TASK_RESPONSE | jq .
TASK_ID=$(echo $TASK_RESPONSE | jq -r '._id')
sleep 1

# Test 6: Get All Tasks
echo ""
echo "📌 Test 6: Get All Tasks"
curl -s "$BASE_URL/api/tasks" \
  -H "Authorization: Bearer $TOKEN" | jq .
sleep 1

# Test 7: Get Task by ID
echo ""
echo "📌 Test 7: Get Task by ID"
curl -s "$BASE_URL/api/tasks/$TASK_ID" \
  -H "Authorization: Bearer $TOKEN" | jq .
sleep 1

# Test 8: Update Task
echo ""
echo "📌 Test 8: Update Task"
curl -s -X PUT "$BASE_URL/api/tasks/$TASK_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "in progress",
    "priority": "Khẩn cấp"
  }' | jq .
sleep 1

# Test 9: Get Stats
echo ""
echo "📌 Test 9: Get Stats"
curl -s "$BASE_URL/api/tasks/stats" \
  -H "Authorization: Bearer $TOKEN" | jq .
sleep 1

# Test 10: Add Comment
echo ""
echo "📌 Test 10: Add Comment"
curl -s -X POST "$BASE_URL/api/comments" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"taskId\": \"$TASK_ID\",
    \"content\": \"This is a test comment\"
  }" | jq .
sleep 1

# Test 11: Get Comments
echo ""
echo "📌 Test 11: Get Comments"
curl -s "$BASE_URL/api/comments/task/$TASK_ID" \
  -H "Authorization: Bearer $TOKEN" | jq .
sleep 1

# Test 12: Delete Task
echo ""
echo "📌 Test 12: Delete Task"
curl -s -X DELETE "$BASE_URL/api/tasks/$TASK_ID" \
  -H "Authorization: Bearer $TOKEN" | jq .

echo ""
echo "======================================"
echo "✅ ALL TESTS COMPLETED!"
echo "======================================"
