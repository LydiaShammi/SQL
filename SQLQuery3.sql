CREATE TABLE mytab(
   ID                    VARCHAR(1) NOT NULL PRIMARY KEY
  ,ParentID              VARCHAR(1) NOT NULL
  ,CreatedTimestamp      VARCHAR(19) NOT NULL
  ,FirstResponseTimemins INTEGER  NOT NULL
  ,SolvedTimestamp       DATE 
  ,AgentID               VARCHAR(2) NOT NULL
  ,Rating                INTEGER 
  ,Vertical              VARCHAR(7) NOT NULL
  ,Status                VARCHAR(25) NOT NULL
);

INSERT INTO mytab(ID,ParentID,CreatedTimestamp,FirstResponseTimemins,SolvedTimestamp,AgentID,Rating,Vertical,Status) VALUES ('a','b','25-02-2021 12:00',45,NULL,'XY',NULL,'Profile','Customer response pending');
INSERT INTO mytab(ID,ParentID,CreatedTimestamp,FirstResponseTimemins,SolvedTimestamp,AgentID,Rating,Vertical,Status) VALUES ('b','b','01-13-2021 2:00',123,'01-15-2021','AJ',2,'Profile','Solved');
INSERT INTO mytab(ID,ParentID,CreatedTimestamp,FirstResponseTimemins,SolvedTimestamp,AgentID,Rating,Vertical,Status) VALUES ('c','-','01-01-2021 15:00',24,'05-01-2021','YH',3,'Profile','Solved');
INSERT INTO mytab(ID,ParentID,CreatedTimestamp,FirstResponseTimemins,SolvedTimestamp,AgentID,Rating,Vertical,Status) VALUES ('d','-','01-01-2021 15:00',230,'05-14-2021','YW',4,'UPI','Solved');
select * from mytab;