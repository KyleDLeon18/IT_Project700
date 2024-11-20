CREATE TABLE PersonalityTestQuestions (
    question_id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_text TEXT NOT NULL,
    question_type TEXT NOT NULL CHECK (question_type IN ('yes_no', 'multiple_choice')) -- Removed trailing comma
);
CREATE TABLE PersonalityTestResults (
    result_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    question_id INTEGER,
    answer TEXT NOT NULL, -- Store the answer (e.g., 'E' or 'I')
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (question_id) REFERENCES PersonalityTestQuestions(question_id)
);
CREATE TABLE JobFields (
    job_field_id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_field_name TEXT NOT NULL,
    description TEXT NOT NULL
);
CREATE TABLE Courses (
    course_id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_name TEXT NOT NULL,
    description TEXT NOT NULL,
    required_education_level TEXT NOT NULL,
    job_field_id INTEGER,
    FOREIGN KEY (job_field_id) REFERENCES JobFields(job_field_id)
);
CREATE TABLE Schools (
    school_id INTEGER PRIMARY KEY AUTOINCREMENT,
    school_name TEXT NOT NULL,
    location TEXT NOT NULL,
    contact_info TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    email TEXT NOT NULL
);
CREATE TABLE SchoolSubjects (
    subject_id INTEGER PRIMARY KEY AUTOINCREMENT,
    school_id INTEGER,
    subject_name TEXT NOT NULL,
    description TEXT NOT NULL,
    FOREIGN KEY (school_id) REFERENCES Schools(school_id)
);
CREATE TABLE JobFieldMatches (
    match_id INTEGER PRIMARY KEY AUTOINCREMENT,
    result_id INTEGER,
    job_field_id INTEGER,
    match_score REAL NOT NULL,
    FOREIGN KEY (result_id) REFERENCES PersonalityTestResults(result_id),
    FOREIGN KEY (job_field_id) REFERENCES JobFields(job_field_id)
);
CREATE INDEX idx_courses_name ON Courses(course_name);
CREATE INDEX idx_jobfieldmatches_userid ON JobFieldMatches(result_id);
CREATE TABLE PersonalityTestAnswers (
    answer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    answer_text TEXT NOT NULL,
    question_id INTEGER, answer_value INTEGER, category TEXT,
    FOREIGN KEY (question_id) REFERENCES PersonalityTestQuestions(question_id)
);
CREATE TABLE Users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL, -- Ensure passwords are hashed before storing
    name TEXT NOT NULL,
    surname TEXT NOT NULL,
    mobile_number TEXT NOT NULL CHECK (
        mobile_number GLOB '+[0-9]*' OR mobile_number GLOB '[0-9]*'
    ),
    date_of_birth TEXT NOT NULL,  -- Remove the CHECK constraint
    education_level TEXT NOT NULL
);
CREATE TABLE PersonalityTestScores (
    score_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    E INTEGER NOT NULL DEFAULT 0,
    I INTEGER NOT NULL DEFAULT 0,
    S INTEGER NOT NULL DEFAULT 0,
    N INTEGER NOT NULL DEFAULT 0,
    T INTEGER NOT NULL DEFAULT 0,
    F INTEGER NOT NULL DEFAULT 0,
    J INTEGER NOT NULL DEFAULT 0,
    P INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
CREATE TABLE IF NOT EXISTS "user_personality_types" (
        id INTEGER NOT NULL, 
        user_id INTEGER NOT NULL, 
        primary_personality_type VARCHAR NOT NULL, 
        alternative_1 VARCHAR, 
        alternative_2 VARCHAR, 
        alternative_3 VARCHAR, 
        PRIMARY KEY (id), 
        FOREIGN KEY(user_id) REFERENCES "Users" (user_id)
);
CREATE TABLE Skills (
    skill_id INTEGER PRIMARY KEY AUTOINCREMENT,
    skill_name TEXT UNIQUE
);
CREATE TABLE Hobbies (
    hobby_id INTEGER PRIMARY KEY AUTOINCREMENT,
    hobby_name TEXT UNIQUE
);
CREATE TABLE user_hobbies (
    user_id INTEGER PRIMARY KEY,
    main_hobby_id INTEGER NOT NULL,
    additional_hobby_1_id INTEGER,
    additional_hobby_2_id INTEGER,
    additional_hobby_3_id INTEGER,
    FOREIGN KEY(user_id) REFERENCES Users(user_id),  -- Connects to Users table
    FOREIGN KEY(main_hobby_id) REFERENCES hobbies(hobby_id),
    FOREIGN KEY(additional_hobby_1_id) REFERENCES hobbies(hobby_id),
    FOREIGN KEY(additional_hobby_2_id) REFERENCES hobbies(hobby_id),
    FOREIGN KEY(additional_hobby_3_id) REFERENCES hobbies(hobby_id)
);
CREATE TABLE user_skills (
    user_id INTEGER PRIMARY KEY,
    main_skill_id INTEGER NOT NULL,
    additional_skill_1_id INTEGER,
    additional_skill_2_id INTEGER,
    additional_skill_3_id INTEGER,
    FOREIGN KEY(user_id) REFERENCES Users(user_id),  -- Connects to Users table
    FOREIGN KEY(main_skill_id) REFERENCES skills(skill_id),
    FOREIGN KEY(additional_skill_1_id) REFERENCES skills(skill_id),
    FOREIGN KEY(additional_skill_2_id) REFERENCES skills(skill_id),
    FOREIGN KEY(additional_skill_3_id) REFERENCES skills(skill_id)
);