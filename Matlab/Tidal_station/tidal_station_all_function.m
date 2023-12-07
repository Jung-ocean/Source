function data2020DTDT102020KR = importfile(filename, dataLines)
%IMPORTFILE 텍스트 파일에서 데이터 가져오기
%  DATA2020DTDT102020KR = IMPORTFILE(FILENAME)은 디폴트 선택 사항에 따라 텍스트 파일
%  FILENAME에서 데이터를 읽습니다.  데이터를 테이블로 반환합니다.
%
%  DATA2020DTDT102020KR = IMPORTFILE(FILE, DATALINES)는 텍스트 파일 FILENAME의
%  데이터를 지정된 행 간격으로 읽습니다. DATALINES를 양의 정수 스칼라로 지정하거나 양의 정수 스칼라로 구성된 Nx2
%  배열(인접하지 않은 행 간격인 경우)로 지정하십시오.
%
%  예:
%  data2020DTDT102020KR = importfile("D:\Data\Ocean\조위관측소\wind\data_2020_DT_DT_10_2020_KR.txt", [5, Inf]);
%
%  READTABLE도 참조하십시오.
%
% MATLAB에서 2021-12-02 12:17:07에 자동 생성됨

%% 입력 처리

% dataLines를 지정하지 않는 경우 디폴트 값을 정의하십시오.
if nargin < 2
    dataLines = [5, Inf];
end

%% 가져오기 옵션을 설정하고 데이터 가져오기
opts = delimitedTextImportOptions("NumVariables", 15, "Encoding", "UTF-8");

% 범위 및 구분 기호 지정
opts.DataLines = dataLines;
opts.Delimiter = "\t";

% 열 이름과 유형 지정
opts.VariableNames = ["VarName1", "cm", "VarName3", "PSU", "m", "sec", "m1", "sec1", "ms", "points", "deg", "VarName12", "hPa", "m2", "VarName15"];
opts.VariableTypes = ["datetime", "double", "double", "double", "categorical", "categorical", "categorical", "categorical", "double", "categorical", "double", "double", "double", "categorical", "string"];

% 파일 수준 속성 지정
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 변수 속성 지정
opts = setvaropts(opts, "VarName15", "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["m", "sec", "m1", "sec1", "points", "m2", "VarName15"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "VarName1", "InputFormat", "yyyy-MM-dd HH:mm:ss");

% 데이터 가져오기
data2020DTDT102020KR = readtable(filename, opts);

end