# System Monitoring Scripts Collection Analysis

เอกสารฉบับนี้จัดทำขึ้นเพื่อรวบรวม วิเคราะห์ และสรุปผลการทำงานของ Shell Scripts สำหรับการตรวจสอบสถานะระบบ (System Monitoring) จำนวน 8 ไฟล์ โดยแต่ละสคริปต์มีระเบียบวิธี (Methodology) ในการดึงข้อมูล การประมวลผล และการแสดงผลที่แตกต่างกัน ดังรายละเอียดต่อไปนี้

---

## 1. Tongtong.sh
**ผู้พัฒนา/โปรเจกต์:** Tongtong
**รูปแบบการทำงาน:** Template-based HTML Generation (Injection)

สคริปต์นี้มีความซับซ้อนสูงสุดในกลุ่ม โดยเน้นความแม่นยำของการคำนวณทรัพยากรในระดับ Kernel
* **Data Acquisition (การได้มาซึ่งข้อมูล):** ไม่ได้พึ่งพาคำสั่งสำเร็จรูปเพียงอย่างเดียว แต่มีการอ่านค่าจาก `/proc/stat` โดยตรงเพื่อคำนวณ CPU Usage แบบ Real-time โดยการ Sampling ข้อมูล 2 ช่วงเวลา (Time slicing) มาหาผลต่างเพื่อคำนวณเปอร์เซ็นต์การใช้งานที่แม่นยำกว่า `top`
* **Network Metrics:** มีการคำนวณ Throughput (RX/TX metrics) โดยอ่านจาก `/sys/class/net/` และคำนวณอัตราการถ่ายโอนข้อมูลเป็น Mbps
* **Processing Logic:** ใช้ `sed` script ขั้นสูงในการแทนค่าตัวแปร (Placeholders) ในไฟล์ Template แยกต่างหาก (`Tongtong_template.html`) ช่วยให้โค้ดส่วน Logic และส่วน View แยกออกจากกันอย่างชัดเจน (Separation of Concerns)

---

## 2. Tongla.sh
**ผู้พัฒนา/โปรเจกต์:** Tongla
**รูปแบบการทำงาน:** Data Serialization (ES6 Module Export)

มีความแตกต่างจากสคริปต์อื่นอย่างมีนัยสำคัญ โดยไม่ได้สร้างไฟล์ HTML เพื่อแสดงผลโดยตรง แต่ทำหน้าที่เป็น **Backend Data Provider**
* **Data Format:** ผลลัพธ์ถูกเขียนให้อยู่ในรูปแบบ JavaScript Object (`export const systemData`) ซึ่งเอื้อต่อการนำไปใช้งานต่อในฝั่ง Client-side (Modern Web Application)
* **Calculation:** มีการแปลงหน่วย Storage จาก KB เป็น GB และคำนวณร้อยละ (Percentage) ผ่าน `awk` เพื่อให้ข้อมูลมีความพร้อมใช้งานทันทีโดยไม่ต้องประมวลผลซ้ำที่ฝั่ง Frontend
* **Timestamp:** มีการกำหนด Timezone เป็น `Asia/Bangkok` อย่างชัดเจนเพื่อความถูกต้องของเวลาท้องถิ่น

---

## 3. student4_script.sh
**ผู้พัฒนา/โปรเจกต์:** Mai
**รูปแบบการทำงาน:** Simple Template Replacement

มุ่งเน้นการตรวจสอบข้อมูลเชิงปริมาณของไฟล์ในระบบ (File System Metrics)
* **Directory Traversal:** ใช้คำสั่ง `find` ร่วมกับ `wc -l` เพื่อนับจำนวน Directory และไฟล์นามสกุล `.txt` ซึ่งเป็นการตรวจสอบเฉพาะทาง (Specific Monitoring)
* **Resource Calculation:** ใช้การคำนวณเลขจำนวนเต็ม (Integer Arithmetic) ผ่าน `awk` สำหรับ CPU และ Memory
* **Templating:** ใช้เทคนิค `sed` แบบพื้นฐานในการแทนค่าในไฟล์ `template.html` โดยเน้นความเรียบง่ายและรวดเร็ว

---

## 4. test.sh
**ผู้พัฒนา/โปรเจกต์:** Pitch
**รูปแบบการทำงาน:** Standalone HTML Generator with Conditional Logic

จุดเด่นคือการฝังตรรกะเพื่อประเมินสถานะความเสี่ยง (Risk Assessment Logic)
* **Conditional Styling:** มีอัลกอริทึมในการตรวจสอบค่า Threshold (เกณฑ์) ของ CPU, Memory และ Disk หากค่าเกินกำหนด (เช่น > 80%) ระบบจะเปลี่ยน Class ของ CSS เป็น `status-warning` หรือ `status-critical` โดยอัตโนมัติ
* **Embedded Visualization:** สร้างไฟล์ HTML แบบ Standalone ที่ฝัง CSS ไว้ภายใน (Internal CSS) พร้อม Progress Bar ที่ปรับความกว้างตามค่าตัวแปรที่ได้จาก Shell Script
* **Auto-Refresh:** มีการฝัง Meta Tag `refresh` ให้หน้ารีโหลดทุก 10 วินาที

---

## 5. script.sh
**ผู้พัฒนา/โปรเจกต์:** Bambu (Sakura Theme)
**รูปแบบการทำงาน:** Dynamic HTML Table Generation

เน้นการวนซ้ำเพื่อสร้างโครงสร้างข้อมูล (Looping & Iteration)
* **Process Parsing:** ใช้ `ps` command เรียงลำดับ Process ตาม CPU usage จากนั้นใช้ `while read loop` เพื่อดึงข้อมูลทีละบรรทัดและสร้าง HTML Table Row (`<tr>`) แบบไดนามิก
* **Aesthetic Engineering:** มีการใช้ CSS Variables (`:root`) ในการจัดการ Theme สี (Sakura Theme) ซึ่งแสดงให้เห็นถึงความใส่ใจใน User Interface (UI) ภายในสคริปต์ Bash
* **String Manipulation:** ใช้การต่อสตริง (String Concatenation) เพื่อรวมแถวของตารางก่อนเขียนลงไฟล์ HTML

---

## 6. student4_script (1).sh
**ผู้พัฒนา/โปรเจกต์:** Nano (Matcha Monitor)
**รูปแบบการทำงาน:** Daemon-like Process & Data Persistence

เป็นสคริปต์เดียวที่มีพฤติกรรมแบบ **Service/Daemon** และมีการเก็บประวัติข้อมูล (History Logging)
* **Infinite Loop:** ทำงานภายใต้ `while true` loop (หรือโครงสร้างที่คล้ายกันในทางปฏิบัติ) เพื่ออัปเดตข้อมูลตลอดเวลาโดยไม่ต้องรันใหม่
* **Data Persistence:** มีการเขียนข้อมูลลงไฟล์ CSV (`history_data.csv`) และใช้คำสั่ง `tail` เพื่อจำกัดขนาดไฟล์ (Log Rotation) ให้เหลือเพียง 5 รายการล่าสุด เพื่อนำมาแสดงผลเป็นกราฟหรือตารางย้อนหลัง
* **Variable Expansion:** ใช้ `bc` ในการคำนวณทศนิยมสำหรับ CPU Load ซึ่งให้ความละเอียดมากกว่า Integer calculation ทั่วไป

---

## 7. Ohm.sh
**ผู้พัฒนา/โปรเจกต์:** Ohm
**รูปแบบการทำงาน:** Hardware Info & CSS Visualization

เน้นการดึงข้อมูลฮาร์ดแวร์และการแสดงผลแบบ Modern UI
* **Hardware Introspection:** ใช้คำสั่ง `lscpu` และ `grep` เพื่อดึงชื่อรุ่นของ CPU (Model Name) และ Kernel Version
* **CSS Integration:** ใช้เทคนิค CSS Gradient และ Progress bar ที่ซับซ้อนกว่าสคริปต์พื้นฐาน ฝังอยู่ใน `cat <<EOF`
* **Execution Flow:** เป็นการทำงานแบบ Linear (Sequential Execution) คือ อ่านค่า -> กำหนดตัวแปร -> เขียนไฟล์ HTML ทับไฟล์เดิม

---

## 8. student2_script.sh
**ผู้พัฒนา/โปรเจกต์:** Toby
**รูปแบบการทำงาน:** Advanced Dashboard with External Dependencies

เป็นสคริปต์ที่มีความทันสมัยและซับซ้อนที่สุดในแง่ของการบูรณาการระบบ (System Integration)
* **External APIs:** มีการเรียกใช้ `curl ifconfig.me` เพื่อดึง Public IP Address ซึ่งเป็นการตรวจสอบ Network ภายนอก
* **Hardware Sensors:** พยายามอ่านค่าอุณหภูมิ CPU ผ่าน `sensors` (lm-sensors package) ซึ่งเป็นการเข้าถึง Hardware Monitoring ขั้นสูง
* **Algorithmic Status:** มีฟังก์ชัน `determine_status()` เพื่อคำนวณสถานะรวมของระบบ (Online/Warning/Offline) ตามเงื่อนไขตรรกะ
* **Modern Frontend Stack:** ใช้ **Tailwind CSS** ผ่าน CDN และออกแบบ UI แบบ Glassmorphism ซึ่งแสดงถึงการประยุกต์ใช้ Modern Web technologies ร่วมกับ Shell Scripting

---

## สรุปภาพรวม (Comparative Summary)

| Script | วิธีการแสดงผล | จุดเด่นทางเทคนิค (Key Technical Feature) |
| :--- | :--- | :--- |
| **Tongtong** | HTML Template Injection | การคำนวณ CPU จาก `/proc/stat` และการใช้ `sed` แทนที่ค่าที่ซับซ้อน |
| **Tongla** | JS Module Export | การส่งออกข้อมูลเป็น Object (Backend-like) และ Timezone handling |
| **Mai** | HTML Template | การนับจำนวนไฟล์และ Directory (`find`) |
| **Pitch** | Standalone HTML | ตรรกะการตัดเกรดสถานะ (Normal/Risk) และ Auto-refresh |
| **Bambu** | Standalone HTML | การวนลูปสร้างตาราง Process และ CSS Variables |
| **Nano** | Standalone HTML (Loop) | การทำงานแบบ Infinite Loop และการเก็บ Log History (CSV) |
| **Ohm** | Standalone HTML | การดึงข้อมูล Hardware Spec (`lscpu`) |
| **Toby** | Standalone HTML (Tailwind) | การใช้ External API, Hardware Sensors และ Tailwind CSS |
