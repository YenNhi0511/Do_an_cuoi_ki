# PowerShell Script để test Backend API trên Windows
# Sử dụng: .\test-api.ps1

$BASE_URL = "http://localhost:5000"
$TOKEN = ""

Write-Host "🧪 TESTING TASK MANAGER API" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Test 1: Health Check
Write-Host "`n📌 Test 1: Health Check" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $BASE_URL -Method Get
    Write-Host "✅ Server is running: $response" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 1

# Test 2: Register
Write-Host "`n📌 Test 2: Register User" -ForegroundColor Yellow
$registerBody = @{
    name = "Test User"
    email = "test@example.com"
    password = "123456"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/auth/register" `
        -Method Post `
        -Body $registerBody `
        -ContentType "application/json"
    $TOKEN = $response.token
    Write-Host "✅ User registered successfully" -ForegroundColor Green
    Write-Host "Token: $TOKEN" -ForegroundColor Gray
} catch {
    Write-Host "⚠️  User might already exist, trying login..." -ForegroundColor Yellow
}
Start-Sleep -Seconds 1

# Test 3: Login
Write-Host "`n📌 Test 3: Login" -ForegroundColor Yellow
$loginBody = @{
    email = "test@example.com"
    password = "123456"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/auth/login" `
        -Method Post `
        -Body $loginBody `
        -ContentType "application/json"
    $TOKEN = $response.token
    Write-Host "✅ Login successful" -ForegroundColor Green
    Write-Host "Token: $TOKEN" -ForegroundColor Gray
} catch {
    Write-Host "❌ Login failed: $_" -ForegroundColor Red
    exit
}
Start-Sleep -Seconds 1

# Test 4: Get Profile
Write-Host "`n📌 Test 4: Get Profile" -ForegroundColor Yellow
try {
    $headers = @{ Authorization = "Bearer $TOKEN" }
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/auth/profile" `
        -Method Get `
        -Headers $headers
    Write-Host "✅ Profile: $($response.name) - $($response.email)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 1

# Test 5: Create Task
Write-Host "`n📌 Test 5: Create Task" -ForegroundColor Yellow
$taskBody = @{
    title = "Test Task from PowerShell"
    description = "This is a test task"
    category = "Testing"
    priority = "Cao"
    deadline = "2025-12-31"
    status = "not started"
} | ConvertTo-Json

try {
    $headers = @{ Authorization = "Bearer $TOKEN" }
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/tasks" `
        -Method Post `
        -Body $taskBody `
        -ContentType "application/json" `
        -Headers $headers
    $TASK_ID = $response._id
    Write-Host "✅ Task created: $($response.title)" -ForegroundColor Green
    Write-Host "Task ID: $TASK_ID" -ForegroundColor Gray
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 1

# Test 6: Get All Tasks
Write-Host "`n📌 Test 6: Get All Tasks" -ForegroundColor Yellow
try {
    $headers = @{ Authorization = "Bearer $TOKEN" }
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/tasks" `
        -Method Get `
        -Headers $headers
    Write-Host "✅ Total tasks: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 1

# Test 7: Update Task
Write-Host "`n📌 Test 7: Update Task" -ForegroundColor Yellow
$updateBody = @{
    status = "in progress"
    priority = "Khẩn cấp"
} | ConvertTo-Json

try {
    $headers = @{ Authorization = "Bearer $TOKEN" }
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/tasks/$TASK_ID" `
        -Method Put `
        -Body $updateBody `
        -ContentType "application/json" `
        -Headers $headers
    Write-Host "✅ Task updated: Status = $($response.status), Priority = $($response.priority)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 1

# Test 8: Get Stats
Write-Host "`n📌 Test 8: Get Stats" -ForegroundColor Yellow
try {
    $headers = @{ Authorization = "Bearer $TOKEN" }
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/tasks/stats" `
        -Method Get `
        -Headers $headers
    Write-Host "✅ Stats:" -ForegroundColor Green
    Write-Host "   Total: $($response.total)" -ForegroundColor White
    Write-Host "   Completed: $($response.completed)" -ForegroundColor White
    Write-Host "   In Progress: $($response.inProgress)" -ForegroundColor White
    Write-Host "   Not Started: $($response.notStarted)" -ForegroundColor White
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 1

# Test 9: Add Comment
Write-Host "`n📌 Test 9: Add Comment" -ForegroundColor Yellow
$commentBody = @{
    taskId = $TASK_ID
    content = "This is a test comment from PowerShell"
} | ConvertTo-Json

try {
    $headers = @{ Authorization = "Bearer $TOKEN" }
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/comments" `
        -Method Post `
        -Body $commentBody `
        -ContentType "application/json" `
        -Headers $headers
    Write-Host "✅ Comment added" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 1

# Test 10: Get Comments
Write-Host "`n📌 Test 10: Get Comments" -ForegroundColor Yellow
try {
    $headers = @{ Authorization = "Bearer $TOKEN" }
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/comments/task/$TASK_ID" `
        -Method Get `
        -Headers $headers
    Write-Host "✅ Total comments: $($response.Count)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 1

# Test 11: Delete Task
Write-Host "`n📌 Test 11: Delete Task" -ForegroundColor Yellow
try {
    $headers = @{ Authorization = "Bearer $TOKEN" }
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/tasks/$TASK_ID" `
        -Method Delete `
        -Headers $headers
    Write-Host "✅ Task deleted: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "✅ ALL TESTS COMPLETED!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
