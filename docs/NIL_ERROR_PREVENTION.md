# Automated Nil Error Prevention

This project includes automated checks to prevent nil errors in views.

## Tools Included

### 1. Rake Task: `views:check_nil_errors`
Scans all view files for potential nil errors.

**Usage:**
```bash
bin/rails views:check_nil_errors
```

**What it checks:**
- Chained method calls without safe navigation
- Direct access to optional associations (teacher, user, student)
- Common nil-prone patterns

### 2. Pre-commit Hook
Automatically runs when you commit view files, warning you about potential nil errors.

**Location:** `.git/hooks/pre-commit`

**To bypass (not recommended):**
```bash
git commit --no-verify
```

### 3. Nil Safety Tests
Test suite that verifies models handle nil associations gracefully.

**Run tests:**
```bash
bin/rails test test/models/nil_safety_test.rb
```

## Best Practices

### Use Safe Navigation Operator
```erb
<!-- ❌ Bad -->
<%= lesson.teacher.name %>

<!-- ✅ Good -->
<%= lesson.teacher&.name %>
```

### Add Presence Checks
```erb
<!-- ✅ Good -->
<% if lesson.teacher.present? %>
  <%= lesson.teacher.name %>
<% end %>
```

### Create Helper Methods
```ruby
# In model
def teacher_name
  teacher&.name || "No Teacher"
end
```

```erb
<!-- In view -->
<%= lesson.teacher_name %>
```

## Running All Checks

Before pushing code:
```bash
# Check views
bin/rails views:check_nil_errors

# Run nil safety tests
bin/rails test test/models/nil_safety_test.rb

# Run full test suite
bin/rails test
```

## Common Patterns to Avoid

### ❌ Unsafe
```erb
<%= @episode.teacher.display_avatar %>
<%= assignment.student.name %>
<%= journal.user.teacher.name %>
```

### ✅ Safe
```erb
<%= @episode.teacher&.display_avatar %>
<% if assignment.student.present? %>
  <%= assignment.student.name %>
<% end %>
<%= journal.user&.teacher&.name %>
```

## Adding New Checks

Edit `lib/tasks/check_nil_errors.rake` to add new patterns:

```ruby
patterns = [
  {
    regex: /\.new_association\.(?!present\?|&)/,
    message: "Direct new_association access without nil check"
  }
]
```
