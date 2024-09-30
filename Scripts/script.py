import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sys
import os



def grades():
    # Load the CSV file
    df = pd.read_csv('main.csv')

    # Convert 'total' column to numeric
    df['total'] = pd.to_numeric(df['total'], errors='coerce')

    # Calculate mean and standard deviation
    mean_mark = df['total'].mean()
    std_dev = df['total'].std()

    # Calculate the minimum mark (K)
    highest_mark = df['total'].max()
    min_mark = highest_mark * 0.3

    # Define grade boundaries
    grades = {
        'AP': mean_mark + 2.2 * std_dev,
        'AA': mean_mark + 1.6 * std_dev,
        'AB': mean_mark + 0.8 * std_dev,
        'BB': mean_mark-0.1,
        'BC': mean_mark - 1 * std_dev,
        'CC': mean_mark - 1.5 * std_dev,
        'DD': min_mark,
        'FF': 0
    }

    # Assign grades based on marks
    def assign_grade(mark):
        for grade, threshold in grades.items():
            if mark >= threshold:
                return grade

    # Add 'Grades' column to DataFrame
    df['Grades'] = df['total'].apply(assign_grade)

    # Sort DataFrame by grades in ascending order
    df_sorted = df.sort_values(by='total', ascending=False)

    # Save sorted DataFrame to grades.csv
    df_sorted.to_csv('grades.csv', index=False)

    # Create pie chart
    grade_counts = df_sorted['Grades'].value_counts()
    plt.pie(grade_counts, labels=grade_counts.index, autopct=lambda pct: f'{int(pct/100*sum(grade_counts))}', startangle=140)
    plt.title('Distribution of Grades')
    plt.savefig('grades.png')
 










def stats():
   
    # read the CSV file into a pandas dataframe
    df = pd.read_csv('main.csv')

    # replace "a" with NaN to handle absences
    df.replace('a', np.nan, inplace=True)

    # convert columns to numeric for calculations
    df.iloc[:, 2:-1] = df.iloc[:, 2:-1].apply(pd.to_numeric)

    # calculate statistics for each exam
    exam_stats = {}
    for exam in df.columns[2:-1]:  # exclude Roll_Number and Name columns
        std_dev = df[exam].std()
        mean = df[exam].mean()
        median = df[exam].median()
        exam_data = df[exam]
        students_count = exam_data.count()
        exam_stats[exam] = {'Count': students_count,'Mean': mean, 'Median': median, 'Std Dev': std_dev}

    # calculate statistics for total marks
    total_mean = df['total'].mean()
    total_median = df['total'].median()
    total_std_dev = df['total'].std()
    total_data = df['total']
    total_students = total_data.count()
    total_stats = {'Total Students': total_students,'Total Mean': total_mean, 'Total Median': total_median, 'Total Std Dev': total_std_dev}
    print("Exam Statistics:\n")
    for exam, stats in exam_stats.items():
        print(f"{exam}\n")
        for key in stats:
            print(f"{key}: {stats[key]}")
        print("\n")
            
    print("=========\n")
    print("Total Stats\n")
    for key in total_stats:
        print(f"{key}: {total_stats[key]}")
    print("\n")








def visualize() :

    # Load the student data from the CSV file
    df = pd.read_csv('main.csv')

    # Extract the 'total' column which contains the total marks of students
    total_marks = df['total']

    # Find the highest and lowest marks achieved by students
    max_mark = total_marks.max()
    min_mark = total_marks.min()

    # Determine the bin size for grouping marks into ranges
    bin_size = int((max_mark-min_mark)/20)  # This is the width of each mark range bucket

    # Create bins for different mark ranges based on the highest and lowest marks
    bins = np.arange(min_mark - 1, max_mark + bin_size, bin_size)

    # Count how many students fall into each mark range
    marks_count = pd.cut(total_marks, bins=bins, right=False).value_counts().sort_index()

    # Plotting a bar graph to visualize the distribution of marks
    plt.figure(figsize=(12, 6))
    plt.bar(marks_count.index.astype(str), marks_count.values, color='aqua')
    plt.title('Number of Students in Mark Ranges')
    plt.xlabel('Mark Ranges')
    plt.ylabel('Number of Students')
    plt.xticks(rotation=45)
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.tight_layout()
    plt.savefig('total_report.png')
    # Display the graph showing the number of students in different mark ranges
    # plt.show(block=True)






def calculate_percentile(total_marks, class_totals):
    """
    Calculate the percentile of a student's total marks in the class.

    Parameters:
    total_marks (float): Total marks obtained by the student.
    class_totals (list): List of total marks of all students in the class.

    Returns:
    float: Percentile of the student in the class.
    """
    sorted_class_totals = sorted(class_totals)
    count_below = sum(1 for total in sorted_class_totals if total < total_marks)
    percentile = ((count_below+1) / len(sorted_class_totals)) * 100
    return round(percentile, 2)







def analyze_student_performance(roll_number):
    """
    Analyze the performance of a student based on their roll number.

    Parameters:
    roll_number (str): Roll number of the student.

    """
    # Load main.csv into a DataFrame
    df = pd.read_csv('main.csv')

    # Filter rows for the given roll number
    student_data = df[df['Roll_Number'] == roll_number]

    if len(student_data) == 0:
        return f"Student with Roll Number '{roll_number}' not found in the records."

    # Prepare the analysis report header
    report = f"Performance analysis for student with Roll Number '{roll_number}':\n"

    # Extract exam columns for the student
    exam_columns = [col for col in df.columns if col != 'total' and col != 'Roll_Number' and col != 'Name' ]

    for exam in exam_columns:
        exam_data = student_data[exam].iloc[0]
        try:
            exam_data = float(exam_data)
            exam_mean = df[exam].apply(pd.to_numeric, errors='coerce').mean()
            exam_median = df[exam].apply(pd.to_numeric, errors='coerce').median()
            exam_max = df[exam].apply(pd.to_numeric, errors='coerce').max()
            exam_min = df[exam].apply(pd.to_numeric, errors='coerce').min()
            report += f"\nExam {exam}:\n"
            report += f"Student's Marks: {exam_data}\n"
            report += f"Mean: {exam_mean:.2f}, Median: {exam_median:.2f}, Max: {exam_max:.2f}, Min: {exam_min:.2f}\n"
        except ValueError:
            report += f"\nExam {exam}: Student was absent in this exam.\n"

    # Calculate statistics for the total marks for the entire class
    total_marks = student_data['total'].iloc[0]  # Corrected to use iloc[0]
    total_mean = df['total'].mean()
    total_median = df['total'].median()
    total_max = df['total'].max()
    total_min = df['total'].min()

    # Calculate percentile based on total marks
    class_totals = df['total'].tolist()
    percentile = calculate_percentile(total_marks, class_totals)  # Corrected to use total_marks

    # Add total marks and percentile to the report
    report += f"\nTotal Marks:\n"
    report += f"Student's Total Marks: {total_marks}\n"  # Corrected to show correct total_marks
    report += f"Mean: {total_mean:.2f}, Median: {total_median:.2f}, Max: {total_max:.2f}, Min: {total_min:.2f}\n"
    report += f"Percentile in class: {percentile}"
    print(report)







def generate_report_card_html(roll_number, main_csv, image_path):
    # Load main.csv into a DataFrame
    df = pd.read_csv(main_csv)

    # Filter rows for the given roll number
    student_data = df[df['Roll_Number'] == roll_number]

    if len(student_data) == 0:
        return f"Student with Roll Number '{roll_number}' not found in the records."

    # Prepare the HTML code for the report card
    html_code = f'''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Report Card of Student: {roll_number}</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                background-color: #f0e6d6;
                padding: 20px;
                margin: 0;
            }}
            .container {{
                max-width: 1200px;
                margin: auto;
                padding: 20px;
            }}
            h1 {{
                color: #333;
                text-align: center;
                background-color: #c0b2a1;
                padding: 10px;
                border-radius: 5px;
                margin-bottom: 20px;
            }}
            table {{
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 20px;
                box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
                background-color: #fff;
            }}
            th, td {{
                border: 1px solid #ddd;
                padding: 10px;
                text-align: center;
                font-weight: bold;
                color: #333;
                background-color: #f2f2f2;
            }}
            tr:nth-child(even) {{
                background-color: #f9f9f9;
            }}
            tr:hover {{
                background-color: #e2e2e2;
            }}
            .absent {{
                color: #dc3545;
                font-style: italic;
            }}
            .report-image {{
                display: block;
                margin: 20px 0;
                border-radius: 10px;
                box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
                max-width: 70%;
            }}
            .image-heading {{
                font-size: 20px;
                font-weight: bold;
                text-align: left;
                color: #333;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Performance Report for Student: {roll_number}</h1>
            <table>
                <tr style="background-color: #007bff; color: #fff;">
                    <th>Exam Name</th>
                    <th>Marks of Student</th>
                    <th>Mean Mark</th>
                    <th>Median Mark</th>
                    <th>Max Mark</th>
                    <th>Min Mark</th>
                </tr>
    '''

    # Extract exam columns for the student
    exam_columns = [col for col in df.columns if col != 'total' and col != 'Roll_Number' and col != 'Name' ]

    for exam in exam_columns:
        exam_data = student_data[exam].iloc[0]
        try:
            exam_data = float(exam_data)
            exam_mean = df[exam].apply(pd.to_numeric, errors='coerce').mean()
            exam_median = df[exam].apply(pd.to_numeric, errors='coerce').median()
            exam_max = df[exam].apply(pd.to_numeric, errors='coerce').max()
            exam_min = df[exam].apply(pd.to_numeric, errors='coerce').min()
            html_code += f'''
            <tr>
                <td>{exam}</td>
                <td>{exam_data}</td>
                <td>{exam_mean:.2f}</td>
                <td>{exam_median:.2f}</td>
                <td>{exam_max:.2f}</td>
                <td>{exam_min:.2f}</td>
            </tr>
            '''
        except ValueError:
            html_code += f'''
            <tr>
                <td>{exam}</td>
                <td class="absent">Student was absent</td>
                <td>N/A</td>
                <td>N/A</td>
                <td>N/A</td>
                <td>N/A</td>
            </tr>
            '''

    # Close the HTML table
    html_code += '''
            </table>
        '''

    # Add the image with heading after the table
    html_code += f'''
        <div>
            <h2 style="background-color: #c0b2a1; text-align: center; margin: 15px;" "class="image-heading" >Student's Performance Overview Over time</h2>
            <img src="{image_path}" alt="Students Performance Report" class="report-image">
        </div>
    '''

    # Close the HTML body and document
    html_code += '''
        </div>
    </body>
    </html>
    '''

    # Save the HTML code to a file
    with open(f"{roll_number}.html", 'w') as file:
        file.write(html_code)
     
    os.system(f"explorer.exe {roll_number}.html")






def preprocess_marks(value):
    try:
        return float(value)
    except ValueError:
        return np.nan






def generate_report_card(roll_number, csv_file):
    # Read the CSV file
    df = pd.read_csv(csv_file)

    # Filter data for the specific student using their roll number
    student_data = df[df['Roll_Number'] == roll_number]

    if student_data.empty:
        print(f"No data found for roll number {roll_number}.")
        return

    # Extract all exam columns dynamically
    exam_columns = [col for col in df.columns if col not in ['Roll_Number', 'Name', 'total']]

    # Preprocess marks data to handle non-numeric values
    for exam in exam_columns:
        df[exam] = df[exam].apply(preprocess_marks)

    # Extract exam names and corresponding marks for the student
    exam_names = []
    marks = []
    for exam in exam_columns:
        exam_names.append(exam)
        if (student_data[exam].values[0] == 'a' ):
            marks.append(0)
        else:
         marks.append(int(student_data[exam].values[0]))

    # Calculate maximum, average, and minimum marks for each exam
    max_marks = [df[exam].max() for exam in exam_names]
    avg_marks = [df[exam].mean() for exam in exam_names]
    min_marks = [df[exam].min() for exam in exam_names]
    
    # Plotting the report card
    plt.figure(figsize=(12, 8))

    # Plotting with custom line widths
    plt.plot(exam_names, marks, marker='o', linewidth=2, label='Student Marks')
    plt.plot(exam_names, max_marks, linestyle='--', linewidth=2, label='Max Marks')
    plt.plot(exam_names, avg_marks, linestyle='-', marker='s', linewidth=2, label='Avg Marks')
    plt.plot(exam_names, min_marks, linestyle=':', marker='^', linewidth=2, label='Min Marks')

    # Customize plot attributes
    plt.title(f'Report Card for Roll Number: {roll_number}', fontsize=16)
    plt.xlabel('Exam Names', fontsize=12)
    plt.ylabel('Marks', fontsize=12)
    plt.legend(fontsize=10)
    plt.grid(True)
    plt.xticks(rotation=45)
    plt.gca().set_facecolor('lightblue')  # Change 'lightblue' to your desired color
    plt.tight_layout()
    
    # Display the report card graph
    plt.savefig(f"{roll_number}.png")







if (sys.argv[1] == "visualize" ):
    visualize()

if ( sys.argv[1] == "stats" ):
    stats()

if ( sys.argv[1] == "report" ):
    roll=sys.argv[2]
    generate_report_card(roll,'main.csv')
    generate_report_card_html(roll,'main.csv',f"{roll}.png")

if (sys.argv[1] == "grade" ):
    grades()

if (sys.argv[1] == "student_stats"):
    roll=sys.argv[2]
    analyze_student_performance(roll)
    