import keyboard
import time

# កំណត់ស្ថានភាពដំបូងគឺ បិទ (False)
is_running = False

# អនុគមន៍សម្រាប់បិទ/បើក (Toggle)
def toggle_auto():
    global is_running
    is_running = not is_running
    if is_running:
        print("Auto F: 🟢 បើក (ON)")
    else:
        print("Auto F: 🔴 បិទ (OFF)")

# កំណត់អក្សរ 'e' ជាប៊ូតុងសម្រាប់បិទ/បើក
keyboard.add_hotkey('e', toggle_auto)

print("កម្មវិធីកំពុងដើរ... ចុចអក្សរ 'e' ដើម្បីបិទ/បើក Auto F។")
print("ចុចអក្សរ 'esc' ជាប់ដើម្បីបិទកម្មវិធីទាំងស្រុង។")

# ដំណើរការកូដរហូតដល់អ្នកចុច 'esc'
while not keyboard.is_pressed('esc'):
    if is_running:
        keyboard.send('f') # បញ្ជាឲ្យចុចអក្សរ F
        time.sleep(0.1)    # ល្បឿន (0.1 វិនាទីម្តង)
    else:
        time.sleep(0.05)   # សម្រាកពេលបិទ ដើម្បីកុំឲ្យកុំព្យូទ័រដើរធ្ងន់
