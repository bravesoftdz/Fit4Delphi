unit MusicLibrary;

interface

uses
  Classes, SysUtils, TestFramework, Music;

type
  TMusicLibrary = class (TObject)
  protected
    FLibrary: string;
    FSelectIndex: Integer;
    MusicLibrary : TList;
    function GetCount: Integer;
    function GetSelectedSong: TMusic;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadLibrary(FileName : string);
    procedure Select(index : integer);
    procedure SetSongAsSelected (index : Integer);
    function GetSong(Index : integer) : TMusic;
    procedure findAlbum(a : string);
    procedure findArtist(a : string);
    procedure findAll;
    function CountSelectedSongs : Integer;
    procedure DisplayContents(results : TList);

    property Count: Integer read GetCount;
    property Selected: Integer read FSelectIndex;
    property SelectedSong: TMusic read GetSelectedSong;
  end;

  TTestMusicLibrary = class (TTestCase)
  protected
    MusicLibrary: TMusicLibrary;
    procedure Setup; override;
    procedure TearDown; override;
  published
    procedure testArtist;
    procedure testLoadLibrary;
    procedure testName;
    procedure testSelect;
    procedure testNoSongsSelected;
    procedure testMysteriousTraveler;
    procedure testDisplayContents;
  end;

var
  looking : TMusic;

procedure searchComplete;
procedure Select(index : integer);
procedure findAlbum(a: string);
procedure findArtist(a : string);
procedure findAll;
procedure search(seconds : double);
function displayCount : integer;
function SelectedSong : TMusic;
procedure LoadLibrary(FileName : string);
function Count: Integer;
procedure DisplayContents(results: TList);

implementation

uses
  MusicPlayer, Simulator;

var
  FMusicLibrary : TMusicLibrary;

procedure DisplayContents(results: TList);
begin
  FMusicLibrary.DisplayContents(results);
end;

function Count : Integer;
begin
  result := FMusicLibrary.Count;
end;

procedure Select(index : integer);
begin
  FMusicLibrary.Select(index);
end;

procedure LoadLibrary(FileName : string);
begin
  FMusicLibrary.LoadLibrary(FileName);
end;

function SelectedSong : TMusic;
begin
  result := FMusicLibrary.GetSelectedSong;
end;

function displayCount : integer;
begin
(*
    static int displayCount() {
        int count = 0;
        for (int i=0; i<library.length; i++) {
            count += (library[i].selected ? 1 : 0);
        }
        return count;
    }
*)
  result := FMusicLibrary.CountSelectedSongs;
end;

procedure Search(seconds : double);
begin
(*
    static void search(double seconds){
        Music.status = "searching";
        Simulator.nextSearchComplete = Simulator.schedule(seconds);
    }
*)
  Music.status := 'searching';
  Simulator.nextSearchComplete := Simulator.schedule(seconds);
end;

procedure findAlbum(a: string);
begin
(*
    static void findAlbum(String a) {
        search(1.1);
        for (int i=0; i<library.length; i++) {
            library[i].selected = library[i].album.equals(a);
        }
    }
*)
  search(1.1);
  FMusicLibrary.findAlbum(a);
end;

procedure findArtist(a : string);
begin
  search(2.3);
  FMusicLibrary.findArtist(a);
end;

procedure findAll;
begin
  search(3.2);
  FMusicLibrary.findAll;
end;

procedure searchComplete;
begin
(*
    static void searchComplete() {
        Music.status = MusicPlayer.playing == null ? "ready" : "playing";
    }
*)
  if MusicPlayer.playing = nil then
    Music.status := 'ready'
  else
    Music.status := 'playing';
end;

{ TTestMusicLibrary }

{
****************************** TTestMusicLibrary *******************************
}
procedure TTestMusicLibrary.Setup;
begin
  inherited;
  MusicLibrary := TMusicLibrary.Create;
  MusicLibrary.LoadLibrary('c:\develop\fit\music.txt');
end;

procedure TTestMusicLibrary.TearDown;
begin
  inherited;
  MusicLibrary.Free;
end;

procedure TTestMusicLibrary.testArtist;
begin
  MusicLibrary.Select(1);
  Check(MusicLibrary.SelectedSong.artist = 'Toure Kunda', MusicLibrary.SelectedSong.Artist);
end;

procedure TTestMusicLibrary.testDisplayContents;
var
  results : TList;
  aMusic : TMusic;
begin
  results := TList.Create;
  MusicLibrary.findAlbum('Mysterious Traveller');
  MusicLibrary.DisplayContents(results);
  Check(results.Count=2, IntToStr(results.Count));
  aMusic := results[0];
  Check(aMusic.album = 'Mysterious Traveller', aMusic.album);
  Check(aMusic.title = 'American Tango', aMusic.title);
  aMusic := results[1];
  Check(aMusic.album = 'Mysterious Traveller', aMusic.album);
  Check(aMusic.title = 'Scarlet Woman', aMusic.title);
  results.Free;
end;

procedure TTestMusicLibrary.testLoadLibrary;
begin
  MusicLibrary.LoadLibrary('c:\develop\fit\music.txt');
  Check(MusicLibrary.Count = 37, IntToStr(MusicLibrary.Count));
end;

procedure TTestMusicLibrary.testMysteriousTraveler;
begin
  MusicLibrary.findAlbum('Mysterious Traveller');
  Check(MusicLibrary.CountSelectedSongs = 2, IntToStr(MusicLibrary.CountSelectedSongs));
end;

procedure TTestMusicLibrary.testName;
begin
  MusicLibrary.Select(1);
  Check(MusicLibrary.SelectedSong.title = 'Akila', MusicLibrary.SelectedSong.title);
end;

procedure TTestMusicLibrary.testNoSongsSelected;
begin
  Check(MusicLibrary.CountSelectedSongs = 0, IntToStr(MusicLibrary.CountSelectedSongs));
end;

procedure TTestMusicLibrary.testSelect;
begin
  MusicLibrary.Select(1);
  Check(MusicLibrary.Selected = 1, IntToStr(MusicLibrary.Selected ));
end;

{ TMusicLibrary }

{
******************************** TMusicLibrary *********************************
}
function TMusicLibrary.CountSelectedSongs: Integer;
var
  i, iSelCount : integer;
begin
  iSelCount := 0;
  for i := 0 to Count - 1 do begin
    if TMusic(MusicLibrary.Items[i]).Selected then
      Inc(iSelCount);
  end;
  result := iSelCount;
end;

constructor TMusicLibrary.Create;
begin
  MusicLibrary := TList.Create;
end;

destructor TMusicLibrary.Destroy;
begin
  MusicLibrary.Free;
end;

function TMusicLibrary.GetCount: Integer;
begin
  result := MusicLibrary.Count;
end;

function TMusicLibrary.GetSelectedSong: TMusic;
begin
  result := MusicLibrary.Items[FSelectIndex - 1];
end;

function TMusicLibrary.GetSong(Index: integer): TMusic;
begin
  result := TMusic.Create;
end;

procedure TMusicLibrary.LoadLibrary(FileName : string);
var
  i : integer;
  aMusic : TMusic;
  aStringList : TStringList;
begin
  FLibrary := FileName;
  aStringList := TStringList.Create;
  aStringList.LoadFromFile(FLibrary);
  MusicLibrary.Clear;
  for i := 1 to aStringList.Count - 1 do begin
    aMusic := TMusic.Create;
    aMusic.parse(aStringList[i]);
    MusicLibrary.Add(aMusic);
  end;
  aStringList.Free;
end;

procedure TMusicLibrary.Select(index : integer);
begin
  FSelectIndex := index;
  looking := GetSelectedSong;
end;

procedure TMusicLibrary.SetSongAsSelected(index: Integer);
begin
  TMusic(MusicLibrary.Items[Index - 1]).Selected := True;
end;

procedure TMusicLibrary.findAll;
var
  i : integer;
begin
(*
    static void findAll() {
        search(3.2);
        for (int i=0; i<library.length; i++) {
            library[i].selected = true;
        }
    }
*)
  for i := 0 to Count - 1 do
    TMusic(MusicLibrary.Items[i]).Selected := True;
end;

procedure TMusicLibrary.findAlbum(a: string);
var
  i : integer;
  aMusic : TMusic;
begin
(*
    static void findAlbum(String a) {
        search(1.1);
        for (int i=0; i<library.length; i++) {
            library[i].selected = library[i].album.equals(a);
        }
    }
*)
  for i := 1 to Count do begin
    aMusic := TMusic(MusicLibrary.Items[i-1]);
    aMusic.Selected := aMusic.album = a;
  end;
end;

procedure TMusicLibrary.findArtist(a: string);
var
  i : integer;
  aMusic : TMusic;
begin
  for i := 1 to Count do begin
    aMusic := TMusic(MusicLibrary.Items[i-1]);
    aMusic.Selected := aMusic.artist = a;
  end;
end;

procedure TMusicLibrary.DisplayContents(results: TList);
var
  i : integer;
  aMusic : TMusic;
begin
  for i := 1 to Count do begin
    aMusic := TMusic(MusicLibrary.Items[i-1]);
    if aMusic.Selected then
      results.Add(aMusic);
  end;
end;

initialization
  RegisterTest(TTestMusicLibrary.Suite);
  looking := nil;
  FMusicLibrary := TMusicLibrary.Create;

finalization
  FMusicLibrary.Free;

end.
