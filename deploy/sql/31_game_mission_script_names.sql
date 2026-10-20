-- =============================================================================
-- Project_Game34.Mission_Info.Script: rename 74 script class names that do not
-- exist in the PvE mission script set (GameServerScript.AI.Messions.*) used by
-- the phucdz2kk4/Gunny fork (Fighting.Service/bin/Debug/net48/scripts/AI/Messions
-- and Game.Server/GameServerScript/AI/Messions). Each target class was verified to
-- exist there and each old name verified to be absent.
-- NOTE: this repo itself ships no mission scripts (PVEGame loads them with
-- ScriptMgr.CreateInstance(Mission_Info.Script)); copy that scripts folder too.
-- Idempotent: each UPDATE only fires while the old value is still present.
-- =============================================================================
USE [Project_Game34];
GO
SET NOCOUNT ON;
BEGIN TRANSACTION;
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CSM1071' WHERE ID = 1071 AND Script = N'GameServerScript.AI.Messions.GD1071';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CSM1072' WHERE ID = 1072 AND Script = N'GameServerScript.AI.Messions.GD1072';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CNM1171' WHERE ID = 1171 AND Script = N'GameServerScript.AI.Messions.GT1171';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CNM1172' WHERE ID = 1172 AND Script = N'GameServerScript.AI.Messions.GT1172';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CNM1173' WHERE ID = 1173 AND Script = N'GameServerScript.AI.Messions.GT1173';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CHM1271' WHERE ID = 1271 AND Script = N'GameServerScript.AI.Messions.GK1271';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CHM1272' WHERE ID = 1272 AND Script = N'GameServerScript.AI.Messions.GK1272';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CHM1273' WHERE ID = 1273 AND Script = N'GameServerScript.AI.Messions.GK1273';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CHM1274' WHERE ID = 1274 AND Script = N'GameServerScript.AI.Messions.GK1274';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CTM1371' WHERE ID = 1371 AND Script = N'GameServerScript.AI.Messions.GAH1371';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CTM1372' WHERE ID = 1372 AND Script = N'GameServerScript.AI.Messions.GAH1372';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CTM1373' WHERE ID = 1373 AND Script = N'GameServerScript.AI.Messions.GAH1373';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CTM1374' WHERE ID = 1374 AND Script = N'GameServerScript.AI.Messions.GAH1374';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.CTM1375' WHERE ID = 1375 AND Script = N'GameServerScript.AI.Messions.GAH1375';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DCSM2001' WHERE ID = 2001 AND Script = N'GameServerScript.AI.Messions.KD1120';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DCSM2002' WHERE ID = 2002 AND Script = N'GameServerScript.AI.Messions.KD1121';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DCNM2101' WHERE ID = 2101 AND Script = N'GameServerScript.AI.Messions.KT1120';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DCNM2102' WHERE ID = 2102 AND Script = N'GameServerScript.AI.Messions.KT1121';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.ETN3101' WHERE ID = 3101 AND Script = N'GameServerScript.AI.Messions.BLTTT1122';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.ETN3102' WHERE ID = 3102 AND Script = N'GameServerScript.AI.Messions.BLTTT1123';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.ETN3103' WHERE ID = 3103 AND Script = N'GameServerScript.AI.Messions.BLTTT1124';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.ETN3104' WHERE ID = 3106 AND Script = N'GameServerScript.AI.Messions.BLTTT1126';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.ETH3201' WHERE ID = 3201 AND Script = N'GameServerScript.AI.Messions.BLTTK1122';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.ETH3202' WHERE ID = 3202 AND Script = N'GameServerScript.AI.Messions.BLTTK1123';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.ETH3203' WHERE ID = 3203 AND Script = N'GameServerScript.AI.Messions.BLTTK1124';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.ETH3204' WHERE ID = 3206 AND Script = N'GameServerScript.AI.Messions.BLTTK1126';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.ETT3301' WHERE ID = 3301 AND Script = N'GameServerScript.AI.Messions.BLTTAH1122';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.ETT3302' WHERE ID = 3302 AND Script = N'GameServerScript.AI.Messions.BLTTAH1123';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.ETT3303' WHERE ID = 3303 AND Script = N'GameServerScript.AI.Messions.BLTTAH1124';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.ETT3304' WHERE ID = 3306 AND Script = N'GameServerScript.AI.Messions.BLTTAH1126';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DCN4101' WHERE ID = 4101 AND Script = N'GameServerScript.AI.Messions.PDHAT1142';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DCN4102' WHERE ID = 4102 AND Script = N'GameServerScript.AI.Messions.PDHAT1143';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DCN4103' WHERE ID = 4103 AND Script = N'GameServerScript.AI.Messions.PDHAT1144';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DCH4201' WHERE ID = 4201 AND Script = N'GameServerScript.AI.Messions.PDHAK1142';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DCH4202' WHERE ID = 4202 AND Script = N'GameServerScript.AI.Messions.PDHAK1143';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DCH4203' WHERE ID = 4203 AND Script = N'GameServerScript.AI.Messions.PDHAK1144';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DCT4301' WHERE ID = 4301 AND Script = N'GameServerScript.AI.Messions.PDHAAH1142';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DCT4302' WHERE ID = 4302 AND Script = N'GameServerScript.AI.Messions.PDHAAH1143';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DCT4303' WHERE ID = 4303 AND Script = N'GameServerScript.AI.Messions.PDHAAH1144';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DLN5101' WHERE ID = 5101 AND Script = N'GameServerScript.AI.Messions.DCR5101';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DLN5102' WHERE ID = 5102 AND Script = N'GameServerScript.AI.Messions.DCR5102';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DLN5103' WHERE ID = 5103 AND Script = N'GameServerScript.AI.Messions.DCR5103';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DLN5104' WHERE ID = 5104 AND Script = N'GameServerScript.AI.Messions.DCR5104';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DLH5201' WHERE ID = 5201 AND Script = N'GameServerScript.AI.Messions.DCR5201';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DLH5202' WHERE ID = 5202 AND Script = N'GameServerScript.AI.Messions.DCR5202';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DLH5203' WHERE ID = 5203 AND Script = N'GameServerScript.AI.Messions.DCR5203';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DLH5204' WHERE ID = 5204 AND Script = N'GameServerScript.AI.Messions.DCR5204';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DLT5301' WHERE ID = 5301 AND Script = N'GameServerScript.AI.Messions.DCR5301';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DLT5302' WHERE ID = 5302 AND Script = N'GameServerScript.AI.Messions.DCR5302';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DLT5303' WHERE ID = 5303 AND Script = N'GameServerScript.AI.Messions.DCR5303';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.DLT5304' WHERE ID = 5304 AND Script = N'GameServerScript.AI.Messions.DCR5304';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.GON6101' WHERE ID = 6101 AND Script = N'GameServerScript.AI.Messions.DTGT1165';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.GON6102' WHERE ID = 6102 AND Script = N'GameServerScript.AI.Messions.DTGT1166';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.GON6103' WHERE ID = 6103 AND Script = N'GameServerScript.AI.Messions.DTGT1167';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.GON6104' WHERE ID = 6104 AND Script = N'GameServerScript.AI.Messions.DTGT1168';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.GOH6201' WHERE ID = 6201 AND Script = N'GameServerScript.AI.Messions.DTGK1165';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.GOH6202' WHERE ID = 6202 AND Script = N'GameServerScript.AI.Messions.DTGK1166';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.GOH6203' WHERE ID = 6203 AND Script = N'GameServerScript.AI.Messions.DTGK1167';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.GOH6204' WHERE ID = 6204 AND Script = N'GameServerScript.AI.Messions.DTGK1168';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.GOT6301' WHERE ID = 6301 AND Script = N'GameServerScript.AI.Messions.DTGAH1165';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.GOT6302' WHERE ID = 6302 AND Script = N'GameServerScript.AI.Messions.DTGAH1166';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.GOT6303' WHERE ID = 6303 AND Script = N'GameServerScript.AI.Messions.DTGAH1167';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.GOT6304' WHERE ID = 6304 AND Script = N'GameServerScript.AI.Messions.DTGAH1168';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.RRCS7001' WHERE ID = 7001 AND Script = N'GameServerScript.AI.Messions.GCGCD1161';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.RRCS7002' WHERE ID = 7002 AND Script = N'GameServerScript.AI.Messions.GCGCD1162';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.RRCS7004' WHERE ID = 7004 AND Script = N'GameServerScript.AI.Messions.GCGCD1164';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.RRCN7101' WHERE ID = 7101 AND Script = N'GameServerScript.AI.Messions.GCGCT1161';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.RRCN7102' WHERE ID = 7102 AND Script = N'GameServerScript.AI.Messions.GCGCT1162';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.RRCN7103' WHERE ID = 7103 AND Script = N'GameServerScript.AI.Messions.GCGCT1163';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.RRCN7104' WHERE ID = 7104 AND Script = N'GameServerScript.AI.Messions.GCGCT1164';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.RRCH7201' WHERE ID = 7201 AND Script = N'GameServerScript.AI.Messions.GCGCK1161';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.RRCH7202' WHERE ID = 7202 AND Script = N'GameServerScript.AI.Messions.GCGCK1162';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.RRCH7203' WHERE ID = 7203 AND Script = N'GameServerScript.AI.Messions.GCGCK1163';
UPDATE dbo.Mission_Info SET Script = N'GameServerScript.AI.Messions.RRCH7204' WHERE ID = 7204 AND Script = N'GameServerScript.AI.Messions.GCGCK1164';
COMMIT TRANSACTION;
GO
