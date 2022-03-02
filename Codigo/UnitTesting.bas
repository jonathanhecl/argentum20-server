Attribute VB_Name = "UnitTesting"
'********************* COPYRIGHT NOTICE*********************
' Copyright (c) 2021-22 Martin Trionfetti, Pablo Marquez
' www.ao20.com.ar
' All rights reserved.
' Refer to licence for conditions of use.
' This copyright notice must always be left intact.
'****************** END OF COPYRIGHT NOTICE*****************
'
Option Explicit

Private unit_client As Network.Client
Private exit_client As Boolean
Public unit_public_key As String


Public Sub WriteLoginNewChar(ByVal username As String)
    Dim encrypted_username_b64 As String
     'encrypted_username_b64 = AO20CryptoSysWrapper.ENCRYPT(cnvHexStrFromBytes(unit_public_key), UserName)
'     Call Writer.WriteInt(ClientPacketID.LoginNewChar)
'     Call Writer.WriteString8(encrypted_session_token)
'     Call Writer.WriteString8(encrypted_username_b64)
'     Call Writer.WriteInt8(App.Major)
'     Call Writer.WriteInt8(App.Minor)
'     Call Writer.WriteInt8(App.Revision)
'     Call Writer.WriteString8(CheckMD5)
'     Call Writer.WriteInt8(UserRaza)
'     Call Writer.WriteInt8(UserSexo)
'     Call Writer.WriteInt8(UserClase)
'     Call Writer.WriteInt16(MiCabeza)
'     Call Writer.WriteInt8(UserHogar)
'     Call modNetwork.Send(Writer)
End Sub
    
Private Function Create1stMessage() As Network.Writer
    Set Create1stMessage = New Network.Writer
    
    Call Create1stMessage.WriteInt(0)
    Call Create1stMessage.WriteString8("Hello, World")
End Function

Private Function Create2ndMessage() As Network.Writer
    Set Create2ndMessage = New Network.Writer
    
    Call Create2ndMessage.WriteInt(1)
    Call Create2ndMessage.WriteString8("Goodbye!")
End Function

Private Sub OnClientAttach()
    Debug.Print "OnClientAttach"
End Sub

Private Sub OnClientDetach(ByVal Code As Long)
    Debug.Print "OnClientDetach", Code
    exit_client = True
End Sub

Private Sub OnClientForward(ByVal Buffer As Network.Reader)
    Debug.Print "OnClientForward", Buffer.GetAvailable()
    
    Dim BufferRef() As Byte
    Call Buffer.getData(BufferRef)
    
End Sub

Private Sub OnClientReceive(ByVal Buffer As Network.Reader)
    Debug.Print "OnClientReceive", Buffer.GetAvailable()

    Dim BufferRef() As Byte
    Call Buffer.getData(BufferRef)
    
    
    Select Case Buffer.ReadInt()
        Case 0
            Debug.Print "Create1stMessage", Buffer.ReadString8()
            Call unit_client.Send(False, Create2ndMessage())
    End Select
End Sub


Function test_proto()
test_proto = False
    unit_public_key = "pabloMARQUEZArg1"

    Set unit_client = New Network.Client
    Call unit_client.Attach(AddressOf OnClientAttach, AddressOf OnClientDetach, AddressOf OnClientForward, AddressOf OnClientReceive)
    Call unit_client.Connect("127.0.0.1", "7667")
    Do While (Not exit_client)
        Call unit_client.Flush
        Call unit_client.Poll
        DoEvents
    Loop
    Call unit_client.Close(True)

test_proto = True
End Function

Sub test_make_user(ByVal userindex As Integer, ByVal map As Integer, ByVal x As Integer, ByVal y As Integer)
UserList(userindex).Pos.map = map
UserList(userindex).Pos.x = x
UserList(userindex).Pos.y = y
Call MakeUserChar(True, 17, userindex, map, x, y, 1)
End Sub

Function test_percentage() As Boolean
Dim sw As Instruments
Set sw = New Instruments
sw.start
Debug.Assert (Porcentaje(100#, 1#) = 1)
Debug.Assert (Porcentaje(100#, 2#) = 2)
Debug.Assert (Porcentaje(100#, 5#) = 5)
Debug.Assert (Porcentaje(100#, 10#) = 10)
Debug.Assert (Porcentaje(100#, 100#) = 100)
Dim i As Integer
For i = 1 To 100
        Debug.Assert Porcentaje(100#, i) = i
Next i
For i = 1 To 1000
        Debug.Assert Porcentaje(1000#, i) = i * 10
Next i
Debug.Print "Porcentaje took " & sw.ElapsedMilliseconds; " ms"
test_percentage = True
End Function

Function test_distance() As Boolean
Dim sw As Instruments
Set sw = New Instruments
sw.start
Debug.Assert Distance(0, 0, 0, 0) = 0
Dim i As Integer
For i = 1 To 100
        Debug.Assert Distance(i, 0, 0, 0) = i
Next i
For i = 1 To 1000
       Debug.Assert Distance(i, 0, -i, 0) = i + i
Next i
Debug.Print "distace took " & sw.ElapsedMilliseconds; " ms"
test_distance = True
End Function


Function test_random_number() As Boolean

Dim sw As Instruments
Set sw = New Instruments
sw.start

Debug.Assert RandomNumber(0, 0) = 0
Debug.Assert RandomNumber(-1, -1) = -1
Debug.Assert RandomNumber(1, 1) = 1
Dim i As Integer
Dim n As Integer
For i = 1 To 1000
      n = RandomNumber(0, i)
      Debug.Assert n >= 0 And n <= i
Next i
For i = 1 To 1000
      n = RandomNumber(-i, 0)
      Debug.Assert n >= -i And n <= 0
Next i

Debug.Print "random_bumber took " & sw.ElapsedMilliseconds; " ms"
test_random_number = True

End Function


Function test_maths() As Boolean
test_maths = test_percentage() And test_random_number() And test_distance()
End Function

Function test_make_user_char() As Boolean

'Create first User
Call test_make_user(1, 1, 54, 51)
Debug.Assert (MapData(1, 54, 51).userindex = 1)
Debug.Assert (UserList(1).Char.CharIndex <> 0)
'Delete first user
Call EraseUserChar(1, False, False)
Debug.Assert (MapData(1, 54, 55).userindex = 0)
Debug.Assert (UserList(1).Char.CharIndex = 0)
'Delete all NPCs5
Dim i
For i = 1 To UBound(NpcList)
        If NpcList(i).Char.CharIndex <> 0 Then
            Call EraseNPCChar(1)
        End If
Next i

'Create two users on the same map pos
Call test_make_user(2, 1, 54, 56)
Debug.Assert (MapData(1, 54, 56).userindex = 2)
Debug.Assert (UserList(2).Char.CharIndex <> 0)

Call test_make_user(1, 1, 50, 46)
Debug.Assert (MapData(1, 50, 46).userindex = 1)
Debug.Assert (UserList(1).Char.CharIndex <> 0)
Debug.Assert (UserList(2).Char.CharIndex <> UserList(1).Char.CharIndex)

'Delete user 2
Call EraseUserChar(2, False, False)
Debug.Assert (MapData(1, 54, 56).userindex = 0)
Debug.Assert (UserList(2).Char.CharIndex = 0)
'Create user 2 again
Call test_make_user(2, 1, 54, 56)
Debug.Assert (MapData(1, 54, 56).userindex = 2)
Debug.Assert (UserList(2).Char.CharIndex <> 0)

For i = 1 To UBound(UserList)
    If UserList(i).Char.CharIndex <> 0 Then
        Call EraseUserChar(i, False, True)
    End If
Next i

Call test_make_user(1, 1, 64, 66)
Debug.Assert (MapData(1, 64, 66).userindex = 1)
Debug.Assert (UserList(1).Char.CharIndex <> 0)
Debug.Assert (UserList(1).Char.CharIndex = 1)


Call test_make_user(1, 1, 68, 66)
Debug.Assert (MapData(1, 68, 66).userindex = 1)
Debug.Assert (UserList(1).Char.CharIndex <> 0)
test_make_user_char = True
End Function

Function test_suite() As Boolean

Dim result As Boolean

result = test_make_user_char()
result = result And test_maths() And test_proto()
test_suite = result
End Function
