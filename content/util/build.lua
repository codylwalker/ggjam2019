---- to do --------------------------------------------------------------------
--
-- + osx build
--   / download binaries
--   / extract (needs powershell unzip)
--   / modify plist
--   / add game archive
--   / compress to zip
-- + build from other platforms
--   ? zip
--   ? unzip
--   ? download
--   . test on linux
--   . test on osx
-- + android
--   / download project
--   / add in / modify files for game 
--   . generate icons
--   / compress project
-- + ios
--   / download project
--   . add in / modify files for game 
--   . ...
--   . compress project
-- + windows icon with resource hacker
--   . provide an icon
--   . download resource hacker
--   . extract all
--   . run with commands to set icon

---- configuration ------------------------------------------------------------

local save_directory = love.filesystem.getSaveDirectory ()
local build_directory = 'build'
local temp_directory = build_directory .. '/_tmp'
-- TODO: handle spaces in identity properly
-- TODO: detect and handle problematic characters in identity
local identity = love.filesystem.getIdentity ()

local app_name = 'dream disc'
local app_identifier = 'com.mindfungus.dreamdisc'
local android_version_code = 2
local android_version_name = '0.1'

---- util: filenames ----------------------------------------------------------

local function filename_of_url (url)
  return string.match (url, '[^/]*/?$')
end

local function filename_without_extension (filename)
  return string.match (filename, '(.*)%.[^.]+$')
end

---- util: replace all but first ----------------------------------------------

local function skip_first_replacement (replacement)
  local first = true
  return function (str)
    if first then
      first = false
      return nil
    else
      return replacement
    end
  end
end

---- util: delete -------------------------------------------------------------

local function delete_recursively (path)
  if love.filesystem.isDirectory (path) then
    for _, name in ipairs (love.filesystem.getDirectoryItems (path)) do
      delete_recursively (path .. '/' .. name)
    end
    assert (love.filesystem.remove (path))
    print ('deleted folder ' .. path)
  elseif love.filesystem.isFile (path) then
    print ('deleting file ' .. path)
    assert (love.filesystem.remove (path))
    print ('deleted file ' .. path)
  else
    print ('ignored ' .. path)
  end
end

local function filter_directory (path, fn)
  if love.filesystem.isDirectory (path) then
    for _, name in ipairs (love.filesystem.getDirectoryItems (path)) do
      filter_directory (path .. '/' .. name, fn)
    end
  elseif love.filesystem.isFile (path) then
    if not fn (path) then
      assert (love.filesystem.remove (path))
    end
  end
end

---- util: rename -------------------------------------------------------------

local function rename (old, new)
  print ('rename', old, new)
  assert (os.rename (save_directory .. '/' .. old, save_directory .. '/' .. new))
end

---- util: copy file ----------------------------------------------------------

local function copy_file (from, to)
  print ('copy', from, to)

  local from_file = assert (love.filesystem.newFile (from, 'r'))
  local to_file = assert (love.filesystem.newFile (to, 'w'))
  while not from_file:isEOF () do
    assert (to_file:write (from_file:read (128*1024)))
  end
  from_file:close ()
  to_file:close ()
end

---- util: run command and return output --------------------------------------

local function run_command (cmd)
  print ('command: ' .. cmd)
  local stdout = io.popen (cmd)
  local output = stdout:read ('*a')
  stdout:close ()
  print (output)
  return output
end

---- util: powershell ---------------------------------------------------------

local function powershell (command)
  -- https://stackoverflow.com/a/26843122
  local cmd = 
    [[powershell.exe -nologo -noprofile -noninteractive -executionpolicy unrestricted ]] ..
    [[-command "& { $ErrorActionPreference = 'Stop'; ]] .. command ..  [[}" 2>&1]]
  local stdout = io.popen (cmd)
  local output = stdout:read ('*a')
  stdout:close ()
  if output ~= '' then print (output) end
  return not output:match ('Exception'), output
end

---- util: download -----------------------------------------------------------

local function download (url, output)
  if not love.filesystem.exists (output) then
    output = save_directory .. '/' .. output
    print ('download', url, output)

    if love.system.getOS () == 'Windows' then
      -- use powershell on windows
      local success, message = powershell (
          "(New-Object System.Net.WebClient).DownloadFile('" .. url .. "', '" .. output .. "');")
      if not success then
        error ('error downloading ' .. url .. ' to ' .. output .. ': ' .. message)
      end
    else
      -- on unix use curl
      local exit_code = os.execute ('curl -L -o "' .. output .. '" "' .. url .. '"')
      if exit_code ~= 0 then
        error ('error downloading ' .. url .. ' to ' .. output .. ': ' .. exit_code)
      end
    end
  end
end

---- util: zip ----------------------------------------------------------------

local zip_download_url = 'https://bitbucket.org/oliojam/build-tools/raw/db3fea7de1840c8dcb8ac7a18be37c4956c37b08/win32/zip.exe'
local zip_path = temp_directory .. '/zip.exe'
local zip_absolute_path = save_directory .. '/' .. zip_path

local function zip_add (directory, zipfile, excludes)
  -- adjust relative paths to be in the save directory
  -- (but '.' still refers to the current working directory)
  if directory ~= '.' then
    directory = save_directory .. '/' .. directory
  end
  zipfile = save_directory .. '/' .. zipfile
  print ('zip', directory, zipfile)

  -- build zip command
  local zip_cmd = 'zip'
  if love.system.getOS () == 'Windows' then
    download (zip_download_url, zip_path)
    zip_cmd = zip_absolute_path
  end
  local cmd = 'cd "' .. directory .. '" && ' .. zip_cmd .. ' -X -9 -r "' .. zipfile .. '" .' 
  if excludes and #excludes > 0 then
    cmd = cmd .. ' -x'
    for i = 1, #excludes do
      cmd = cmd .. ' "' .. excludes [i] .. '"'
    end
  end
  cmd = cmd .. ' && echo 0 || echo 1'

  -- run
  local output = run_command (cmd)

  -- check for success
  if not output:match ('0%s*$') then
    error ('error creating ' .. zipfile .. ': ' .. output)
  end
end

local function zip (directory, zipfile, excludes)
  delete_recursively (zipfile)
  zip_add (directory, zipfile, excludes)
end

---- util: unzip --------------------------------------------------------------

local unzip_download_url = 'https://bitbucket.org/oliojam/build-tools/raw/db3fea7de1840c8dcb8ac7a18be37c4956c37b08/win32/unzip.exe'
local unzip_path = temp_directory .. '/unzip.exe'
local unzip_absolute_path = save_directory .. '/' .. unzip_path

local function unzip (zipfile, directory)
  zipfile = save_directory .. '/' .. zipfile
  directory = save_directory .. '/' .. directory
  print ('unzip', zipfile, directory)

  local unzip_cmd = 'unzip'
  if love.system.getOS () == 'Windows' then
    download (unzip_download_url, unzip_path)
    unzip_cmd = unzip_absolute_path
  end

  local output = run_command (
    unzip_cmd .. ' "' .. zipfile .. '" -d "' .. directory .. '" && echo 0 || echo 1')

  if not output:match ('0%s*$') then
    error ('error creating ' .. zipfile .. ': ' .. output)
  end
end

---- build --------------------------------------------------------------------

local build = {}

function build.build ()
  if not love.filesystem.isFused () and not love.filesystem.getSource ():match ('%.love$') then
    print 'starting build'

    assert (love.filesystem.createDirectory (build_directory))
    assert (love.filesystem.createDirectory (temp_directory))

    build._build_love ()
    --build._build_win32 ()
    --build._build_macosx ()

    --build._build_steam_win32 () -- depends on win32
    --build._build_steam_macosx () -- depends on macosx
    --build._build_steam_linux ()

    build._build_android ()
    --build._build_ios ()

    print 'finished build'

    love.system.openURL ('file://' .. save_directory .. '/' .. build_directory)
  end
end

---- build: love --------------------------------------------------------------

local love_target = build_directory .. '/' .. identity .. '.love'

function build._build_love ()
  zip ('.', love_target, {
    'data_source/*',
    '.git',
    '.gitignore',
    '*.lnk',
  })
end

---- build: win32 -------------------------------------------------------------

local win32_download_url = 'https://bitbucket.org/rude/love/downloads/love-0.10.2-win32.zip'
local win32_download_filename = filename_of_url (win32_download_url)
local win32_download_name = filename_without_extension (win32_download_filename)
local win32_build_directory = temp_directory .. '/' .. identity .. '-win32'
local win32_content_directory = win32_build_directory .. '/' .. identity
local win32_target = build_directory .. '/' .. identity .. '-win32.zip'

function build._build_win32 ()
  -- download windows binaries
  download (win32_download_url, temp_directory .. '/' .. win32_download_filename)

  -- make directory for windows build
  delete_recursively (win32_build_directory)
  love.filesystem.createDirectory (win32_build_directory)
  -- unzip windows archive to directory
  unzip (temp_directory .. '/' .. win32_download_filename, win32_build_directory)
  -- keep only dlls and license.txt and love.exe
  filter_directory (win32_build_directory, function (path)
    return path:match ('%.dll$') or path:match ('license%.txt$') or path:match ('love%.exe$')
  end)
  rename (win32_build_directory .. '/' .. win32_download_name, win32_content_directory)

  -- read and remove love.exe
  local love_exe = assert (love.filesystem.read (win32_content_directory .. '/love.exe'))
  love.filesystem.remove (win32_content_directory .. '/love.exe')
  -- fused executable = love.exe+game
  local executable = love.filesystem.newFile (win32_content_directory .. '/' .. identity..  '.exe', 'w')
  executable:write (love_exe)
  executable:write (assert (love.filesystem.read (love_target)))
  executable:close ()

  -- readme
  --assert (love.filesystem.write (win32_content_directory .. '/readme.txt',
  --  assert (love.filesystem.read ('readme.txt'))))
  --copy_file ('readme.txt', win32_content_directory .. '/readme.txt')

  -- zip windows build
  zip (win32_build_directory, win32_target)
  -- delete temporary files
  delete_recursively (win32_build_directory)
end

---- build: macosx ------------------------------------------------------------

local macosx_download_url = 'https://bitbucket.org/rude/love/downloads/love-0.10.2-macosx-x64.zip'
local macosx_download_filename = filename_of_url (macosx_download_url)
local macosx_build_directory = temp_directory .. '/' .. identity .. '-macosx'
local macosx_content_directory = macosx_build_directory .. '/' .. identity .. '.app'
local macosx_target = build_directory .. '/' .. identity .. '-macosx.zip'

function build._build_macosx ()
  -- download binaries
  download (macosx_download_url, temp_directory .. '/' .. macosx_download_filename)
  -- make directory for build
  delete_recursively (macosx_build_directory)
  love.filesystem.createDirectory (macosx_build_directory)
  -- unzip binaries to directory
  unzip (temp_directory .. '/' .. macosx_download_filename, macosx_build_directory)
  rename (macosx_build_directory .. '/love.app', macosx_content_directory)
  -- modify Info.plist
  local info = assert (love.filesystem.read (macosx_content_directory .. '/Contents/Info.plist'))
  info = info:gsub ('\t<key>CFBundleDocumentTypes</key>\n\t<array>.-\n\t</array>\n', '')
  info = info:gsub ('\t<key>UTExportedTypeDeclarations</key>\n\t<array>.-\n\t</array>\n', '')
  info = info:gsub ('<string>org.love2d.love</string>', '<string>' .. app_identifier .. '</string>')
  info = info:gsub ('<string>LÖVE</string>', '<string>' .. app_name .. '</string>')
  assert (love.filesystem.write (macosx_content_directory .. '/Contents/Info.plist', info))
  -- add game archive
  assert (love.filesystem.write (macosx_content_directory .. '/Contents/Resources/' .. identity .. '.love',
    assert (love.filesystem.read (love_target))))
  -- add icon
  copy_file ('data_source/macosx/OS X AppIcon.icns', macosx_content_directory .. '/Contents/Resources/OS X AppIcon.icns')
  -- zip macosx build
  zip (macosx_build_directory, macosx_target)
  -- delete temporary files
  delete_recursively (macosx_build_directory)
end

---- build: steam win32 -------------------------------------------------------

local steam_win32_build_directory = temp_directory .. '/' .. identity .. '-steam-win32'
local steam_win32_content_directory = steam_win32_build_directory .. '/' .. identity
local steam_win32_target = build_directory .. '/' .. identity .. '-steam-win32.zip'

function build._build_steam_win32 ()
  -- prepare build directory
  delete_recursively (steam_win32_build_directory)
  love.filesystem.createDirectory (steam_win32_content_directory)
  -- add steam files
  assert (love.filesystem.newFile (steam_win32_content_directory .. '/use_steam', 'w')):close ()
  --copy_file ('data_source/steam/steam_appid.txt', steam_win32_content_directory .. '/steam_appid.txt')
  copy_file ('data_source/steam/win32/steam_api.dll', steam_win32_content_directory .. '/steam_api.dll')
  -- copy windows build zip
  copy_file (win32_target, steam_win32_target)
  -- zip build directory, appending to win32 build
  zip_add (steam_win32_build_directory, steam_win32_target)
  -- delete temporary files
  delete_recursively (steam_win32_build_directory)
end

---- build: steam macosx ------------------------------------------------------

local steam_macosx_build_directory = temp_directory .. '/' .. identity .. '-steam-macosx'
local steam_macosx_content_directory = steam_macosx_build_directory .. '/' .. identity .. '.app'
local steam_macosx_target = build_directory .. '/' .. identity .. '-steam-macosx.zip'

function build._build_steam_macosx ()
  -- prepare build directory
  delete_recursively (steam_macosx_build_directory)
  love.filesystem.createDirectory (steam_macosx_content_directory)
  -- add steam files
  love.filesystem.createDirectory (steam_macosx_content_directory .. '/Contents/Resources')
  assert (love.filesystem.newFile (steam_macosx_content_directory .. '/Contents/Resources/use_steam', 'w')):close ()
  --copy_file ('data_source/steam/steam_appid.txt', steam_macosx_content_directory .. '/Contents/Resources/steam_appid.txt')
  love.filesystem.createDirectory (steam_macosx_content_directory .. '/Contents/Frameworks')
  copy_file ('data_source/steam/macosx/libsteam_api.dylib', steam_macosx_content_directory .. '/Contents/Frameworks/libsteam_api.dylib')
  -- copy macosx build zip
  copy_file (macosx_target, steam_macosx_target)
  -- zip build directory, appending to macosx build
  zip_add (steam_macosx_build_directory, steam_macosx_target)
  -- delete temporary files
  delete_recursively (steam_macosx_build_directory)
end

---- build: steam linux -------------------------------------------------------

local steam_linux_download_url = 'https://bitbucket.org/oliojam/build-tools/raw/1fda505800053a5f4eb85ae541a699696b3b1e90/linux/love-0.10.2-linux-steam-x64.zip'
local steam_linux_download_filename = filename_of_url (steam_linux_download_url)
local steam_linux_download_name = filename_without_extension (steam_linux_download_filename)
local steam_linux_build_directory = temp_directory .. '/' .. identity .. '-steam-linux'
local steam_linux_content_directory = steam_linux_build_directory .. '/' .. identity
local steam_linux_target = build_directory .. '/' .. identity .. '-steam-linux.zip'

function build._build_steam_linux ()
  -- download binaries
  download (steam_linux_download_url, temp_directory .. '/' .. steam_linux_download_filename)
  -- make directory for build
  delete_recursively (steam_linux_build_directory)
  love.filesystem.createDirectory (steam_linux_build_directory)
  -- unzip binaries to directory
  unzip (temp_directory .. '/' .. steam_linux_download_filename, steam_linux_build_directory)
  rename (steam_linux_build_directory .. '/' .. steam_linux_download_name, steam_linux_content_directory)
  -- read and remove love binary
  local love_bin = assert (love.filesystem.read (steam_linux_content_directory .. '/love'))
  love.filesystem.remove (steam_linux_content_directory .. '/love')
  -- fused executable = love.exe+game
  local executable = love.filesystem.newFile (steam_linux_content_directory .. '/' .. identity, 'w')
  executable:write (love_bin)
  executable:write (assert (love.filesystem.read (love_target)))
  executable:close ()
  -- edit run.sh to change the executable name
  local run_sh = assert (love.filesystem.read (steam_linux_content_directory .. '/run.sh'))
  run_sh = run_sh:gsub (' ./love\n', ' ./' .. identity)
  assert (love.filesystem.write (steam_linux_content_directory .. '/run.sh', run_sh))
  -- add steam files
  assert (love.filesystem.newFile (steam_linux_content_directory .. '/use_steam', 'w')):close ()
  love.filesystem.createDirectory (steam_linux_content_directory .. '/lib')
  copy_file ('data_source/steam/linux64/libsteam_api.so', steam_linux_content_directory .. '/lib/libsteam_api.so')
  -- zip build
  zip (steam_linux_build_directory, steam_linux_target)
  -- delete temporary files
  delete_recursively (steam_linux_build_directory)
end

---- build: android -----------------------------------------------------------

-- this version has love 0.11.1 and the new gradle build system
local android_commit = '0ac43aa71714'
local android_download_url = 'https://bitbucket.org/MartinFelis/love-android-sdl2/get/' .. android_commit .. '.zip'
local android_download_filename = 'love-android-sdl2-0.11.1-' .. android_commit .. '.zip'
local android_download_content_dir = 'MartinFelis-love-android-sdl2-' .. android_commit
local android_build_directory = temp_directory .. '/' .. identity .. '-android'
local android_source_directory = android_build_directory .. '/' .. identity .. '-android-source'
local android_target = build_directory .. '/' .. identity .. '-android-source.zip'

function build._build_android ()
  -- download source code
  download (android_download_url, temp_directory .. '/' .. android_download_filename)
  -- make directory for build
  delete_recursively (android_build_directory)
  love.filesystem.createDirectory (android_build_directory)
  -- unzip source code
  unzip (temp_directory .. '/' .. android_download_filename, android_build_directory)
  rename (android_build_directory .. '/' .. android_download_content_dir, android_source_directory)
  -- add game archive
  love.filesystem.createDirectory (android_source_directory .. '/app/src/main/assets/')
  assert (love.filesystem.write (android_source_directory .. '/app/src/main/assets/game.love',
    assert (love.filesystem.read (love_target))))
  -- adjust build.gradle
  local app_build_gradle_path = android_source_directory .. '/app/build.gradle'
  local app_build_gradle = assert (love.filesystem.read (app_build_gradle_path))
    :gsub ('applicationId [^\n]*\n', 'applicationId "' .. app_identifier .. '"\n')
    :gsub ('versionCode [^\n]*\n', 'versionCode ' .. android_version_code .. '\n')
    :gsub ('versionName [^\n]*\n', 'versionName "' .. android_version_name .. '"\n')
    :gsub ('targetSdkVersion 22\n', 'targetSdkVersion 26\n') -- google play store requires at least 26
  assert (love.filesystem.write (app_build_gradle_path, app_build_gradle))
  -- adjust AndroidManifest.xml
  local manifest_path = android_source_directory .. '/app/src/main/AndroidManifest.xml'
  local manifest = assert (love.filesystem.read (manifest_path))
    :gsub ('<(service [^\n]* /)>', '')
    :gsub ('android:screenOrientation="landscape"', 'android:screenOrientation="sensor"')
    :gsub ('<intent%-filter>.-</intent%-filter>', skip_first_replacement (''))
    :gsub ('<activity%s.-</activity>', skip_first_replacement (''))
    :gsub ('org%.love2d%.android%.GameActivity', app_identifier .. '.MainActivity')
    :gsub ('android:label="LÖVE for Android"', 'android:label="' .. app_name .. '"')
  assert (love.filesystem.write (manifest_path, manifest))
  -- create main class
  local activity_path = android_source_directory .. '/love/src/main/java/' .. app_identifier:gsub ('%.', '/')
  love.filesystem.createDirectory (activity_path)
  local activity =
    'package ' .. app_identifier .. ';\n' ..
    'import org.love2d.android.GameActivity;\n' ..
    '\n' ..
    'public class MainActivity extends GameActivity {}\n'
  assert (love.filesystem.write (activity_path .. '/MainActivity.java', activity))

  -- fix current compilation errors:
  -- fixes for build.gradle
  local build_gradle_path = android_source_directory .. '/build.gradle'
  local build_gradle = assert (love.filesystem.read (build_gradle_path))
    :gsub ('gradle:3.0.1', 'gradle:3.2.0') .. '\n\n' ..
    'allprojects {\n' ..
    '    repositories {\n' ..
    '        jcenter()\n' ..
    '        google()\n' ..
    '    }\n' ..
    '}\n'
  assert (love.filesystem.write (build_gradle_path, build_gradle))
  -- fixes for gradle wrapper
  local gradle_wrapper_path = android_source_directory .. '/gradle/wrapper/gradle-wrapper.properties'
  local gradle_wrapper = assert (love.filesystem.read (gradle_wrapper_path))
    :gsub ('gradle%-4%.1%-all%.zip', 'gradle-4.6-all.zip')
  assert (love.filesystem.write (gradle_wrapper_path, gradle_wrapper))

  -- todo: generate icons
  -- zip android source
  zip (android_build_directory, android_target)
end

---- build: ios ---------------------------------------------------------------

local ios_download_url = 'https://bitbucket.org/rude/love/downloads/love-0.10.2-ios-source.zip'
local ios_download_filename = filename_of_url (ios_download_url)
local ios_download_content_dir = filename_without_extension (ios_download_filename)
local ios_build_directory = temp_directory .. '/' .. identity .. '-ios'
local ios_source_directory = ios_build_directory .. '/' .. identity .. '-ios-source'

function build._build_ios ()
  -- download source code
  download (ios_download_url, temp_directory .. '/' .. ios_download_filename)
  -- make directory for build
  delete_recursively (ios_build_directory)
  love.filesystem.createDirectory (ios_build_directory)
  -- unzip source code
  unzip (temp_directory .. '/' .. ios_download_filename, ios_build_directory)
  rename (ios_build_directory .. '/' .. ios_download_content_dir, ios_source_directory)

  -- todo:
  -- adjust configuration
  -- add game archive
  -- generate icons
end

return build

---- unused -------------------------------------------------------------------

---- util: 7z -----------------------------------------------------------------

--local _7z_download_url = 'https://bitbucket.org/oliojam/build-tools/raw/cb94d98d7fd818275f6d372b479d6a31986e10ad/win32/7z.exe'
--local _7z_path = temp_directory .. '/7z.exe'
--
--local function download_7z ()
--  download (_7z_download_url, _7z_path)
--end
--
--local function zip_7z (directory, zipfile, excludes)
--  download_7z ()
--  local cmd = save_directory .. '/' .. _7z_path .. ' a -tzip "' .. zipfile .. '" "' .. directory .. '/*"'
--  if excludes then
--    for i = 1, #excludes do
--      cmd = cmd .. ' "-x!' .. excludes [i] .. '"'
--    end
--  end
--  local stdout = io.popen (cmd)
--  local output = stdout:read ('*a')
--  stdout:close ()
--  if not output:match ('Everything is Ok') then
--    print (output)
--    error ('error creating ' .. zipfile .. ': ' .. output)
--  end
--end
--
--local function unzip_7z (zipfile, directory)
--  download_7z ()
--  local cmd = save_directory .. '/' .. _7z_path .. ' x -tzip "' .. zipfile .. '" -o"' .. directory .. '"'
--  local stdout = io.popen (cmd)
--  local output = stdout:read ('*a')
--  stdout:close ()
--  if not output:match ('Everything is Ok') then
--    print (output)
--    error ('error extracting ' .. zipfile .. ': ' .. output)
--  end
--end

