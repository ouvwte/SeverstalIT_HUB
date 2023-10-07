--�������� ��������� ������� 
CREATE GLOBAL TEMPORARY TABLE Intervals
    (StartDateTime                      DATE,
    EndDateTime                         DATE)
ON COMMIT PRESERVE ROWS;

--������� ������
INSERT INTO Intervals (StartDateTime, EndDateTime) VALUES (TO_DATE('2018-01-01 06:00:00','YYYY-MM-DD HH24:mi:ss'), TO_DATE('2018-01-01 14:00:00','YYYY-MM-DD HH24:mi:ss')),
INSERT INTO Intervals (StartDateTime, EndDateTime) VALUES (TO_DATE('2018-01-01 11:00:00','YYYY-MM-DD HH24:mi:ss'), TO_DATE('2018-01-01 19:00:00','YYYY-MM-DD HH24:mi:ss')),
INSERT INTO Intervals (StartDateTime, EndDateTime) VALUES (TO_DATE('2018-01-01 20:00:00','YYYY-MM-DD HH24:mi:ss'), TO_DATE('2018-01-02 03:00:00','YYYY-MM-DD HH24:mi:ss')),
INSERT INTO Intervals (StartDateTime, EndDateTime) VALUES (TO_DATE('2018-01-02 06:00:00','YYYY-MM-DD HH24:mi:ss'), TO_DATE('2018-01-02 14:00:00','YYYY-MM-DD HH24:mi:ss')),
INSERT INTO Intervals (StartDateTime, EndDateTime) VALUES (TO_DATE('2018-01-02 11:00:00','YYYY-MM-DD HH24:mi:ss'), TO_DATE('2018-01-02 19:00:00','YYYY-MM-DD HH24:mi:ss'));

--�������� ����������� ��������� ����������
--������� ����� ��������� �������, �������� ������������ ���������
CREATE GLOBAL TEMPORARY TABLE Merge_Intervals
    (Start_Time                      DATE,
    End_Time                         DATE)
ON COMMIT DELETE ROWS;

--���������, ����������� �������� ����������� ���������� 
CREATE OR REPLACE PROCEDURE MergeIntervals AS 
  CURSOR q_intervals IS
    SELECT * FROM Intervals ORDER BY start_time;
  current_interval Intervals%ROWTYPE;
BEGIN
  OPEN q_intervals;
  FETCH q_intervals INTO current_interval;

  WHILE q_intervals%FOUND LOOP
    IF current_interval.end_time >= q_intervals.start_time THEN
      -- ���������� ������� �������� � ���������
      IF current_interval.end_time < q_intervals.end_time THEN
        current_interval.end_time := q_intervals.end_time;
      END IF;
    ELSE
      -- ��������� ������� �������� � MergedIntervals
      INSERT INTO MergedIntervals VALUES (current_interval.start_time, current_interval.end_time);
      current_interval := q_intervals%ROWTYPE;
    END IF;

    FETCH c_intervals INTO q_intervals%ROWTYPE;
  END LOOP;

  -- ��������� ��������� �������� � MergedIntervals
  INSERT INTO MergedIntervals VALUES (current_interval.start_time, current_interval.end_time);

  CLOSE c_intervals;
END;

--������ ���������
BEGIN
    MergeIntervals;
END;

--��������� 
SELECT * FROM MergeIntervals; 
