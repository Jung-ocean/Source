function data = importfile(filename, dataLines)
%IMPORTFILE 텍스트 파일에서 데이터 가져오기
%  DATA2012TWKGKG00242012KR = IMPORTFILE(FILENAME)은 디폴트 선택 사항에 따라 텍스트 파일
%  FILENAME에서 데이터를 읽습니다.  데이터를 테이블로 반환합니다.
%
%  DATA2012TWKGKG00242012KR = IMPORTFILE(FILE, DATALINES)는 텍스트 파일
%  FILENAME의 데이터를 지정된 행 간격으로 읽습니다. DATALINES를 양의 정수 스칼라로 지정하거나 양의 정수
%  스칼라로 구성된 Nx2 배열(인접하지 않은 행 간격인 경우)로 지정하십시오.
%
%  예:
%  data2012TWKGKG00242012KR = importfile("D:\Data\Ocean\Buoy\해양관측부이\data_2012_TW_KG_KG_0024_2012_KR.txt", [5, Inf]);
%
%  READTABLE도 참조하십시오.
%
% MATLAB에서 2021-11-15 17:46:09에 자동 생성됨

%% 입력 처리

% dataLines를 지정하지 않는 경우 디폴트 값을 정의하십시오.
if nargin < 2
    dataLines = [5, Inf];
end

%% 가져오기 옵션을 설정하고 데이터 가져오기
opts = delimitedTextImportOptions("NumVariables", 18, "Encoding", "UTF-8");

% 범위 및 구분 기호 지정
opts.DataLines = dataLines;
opts.Delimiter = "\t";

% 열 이름과 유형 지정
opts.VariableNames = ["VarName1", "cms", "points", "deg", "VarName5", "PSU", "MOSEHFm", "MOSEHFsec", "MOSEHFm1", "MOSEHFsec1", "points1", "deg1", "ms", "points2", "deg2", "VarName16", "hPa", "VarName18"];
opts.VariableTypes = ["datetime", "categorical", "categorical", "categorical", "categorical", "categorical", "double", "categorical", "double", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "string"];

% 파일 수준 속성 지정
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 변수 속성 지정
opts = setvaropts(opts, "VarName18", "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["cms", "points", "deg", "VarName5", "PSU", "MOSEHFsec", "MOSEHFsec1", "points1", "deg1", "ms", "points2", "deg2", "VarName16", "hPa", "VarName18"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "VarName1", "InputFormat", "yyyy-MM-dd HH:mm:ss");

% 데이터 가져오기
data = readtable(filename, opts);

end